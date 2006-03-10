!!$ 
!!$              Parallel Sparse BLAS  v2.0
!!$    (C) Copyright 2006 Salvatore Filippone    University of Rome Tor Vergata
!!$                       Alfredo Buttari        University of Rome Tor Vergata
!!$ 
!!$  Redistribution and use in source and binary forms, with or without
!!$  modification, are permitted provided that the following conditions
!!$  are met:
!!$    1. Redistributions of source code must retain the above copyright
!!$       notice, this list of conditions and the following disclaimer.
!!$    2. Redistributions in binary form must reproduce the above copyright
!!$       notice, this list of conditions, and the following disclaimer in the
!!$       documentation and/or other materials provided with the distribution.
!!$    3. The name of the PSBLAS group or the names of its contributors may
!!$       not be used to endorse or promote products derived from this
!!$       software without specific written permission.
!!$ 
!!$  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
!!$  ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
!!$  TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
!!$  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE PSBLAS GROUP OR ITS CONTRIBUTORS
!!$  BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
!!$  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
!!$  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
!!$  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
!!$  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
!!$  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
!!$  POSSIBILITY OF SUCH DAMAGE.
!!$ 
!!$  
! File: psb_dspasb.f90
!
! Subroutine: psb_dspasb
!    Assembly sparse matrix and set psblas communications
!    structures.
! 
! Parameters: 
!    a        - type(<psb_dspmat_type>).          The sparse matrix to be allocated.      
!    desc_a   - type(<psb_desc_type>).            The communication descriptor to be updated.
!    info     - integer.                          Eventually returns an error code.
!    afmt     - character,dimension(5)(optional). The output format.
!    up       - character(optional).              ???
!    dup      - integer(optional).                ???
!
subroutine psb_dspasb(a,desc_a, info, afmt, up, dup)

  use psb_descriptor_type
  use psb_spmat_type
  use psb_serial_mod
  use psb_const_mod
  use psi_mod
  use psb_error_mod

  implicit none

  interface psb_cest
     subroutine psb_cest(afmt, nnz, lia1, lia2, lar, up, info)
       integer, intent(in) ::  nnz 
       integer, intent(out) :: lia1, lia2, lar, info
       character, intent(in) :: afmt*5, up
     end subroutine psb_cest
  end interface

  !...Parameters....
  type(psb_dspmat_type), intent (inout)   :: a
  type(psb_desc_type), intent(in)         :: desc_a
  integer, intent(out)                    :: info
  integer,optional, intent(in)            :: dup
  character, optional, intent(in)         :: afmt*5, up
  !....Locals....
  integer               ::  int_err(5)
  type(psb_dspmat_type) ::  atemp
  real(kind(1.d0))      ::  real_err(5)
  integer               ::  ia1_size,ia2_size,aspk_size,m,i,err,&
       & nprow,npcol,myrow,mycol ,size_req,idup,n_col,iout, err_act
  integer               :: dscstate, spstate, nr,k,j, iupdup
  integer               :: icontxt,temp(2),isize(2),n_row
  character             :: iup
  logical, parameter    :: debug=.false., debugwrt=.false.
  character(len=20)     :: name, ch_err

  info = 0
  int_err(1)=0
  name = 'psb_spasb'
  call psb_erractionsave(err_act)

  icontxt  = desc_a%matrix_data(psb_ctxt_)
  dscstate = desc_a%matrix_data(psb_dec_type_)
  n_row    = desc_a%matrix_data(psb_n_row_)
  n_col    = desc_a%matrix_data(psb_n_col_)

  ! check on BLACS grid 
  call blacs_gridinfo(icontxt, nprow, npcol, myrow, mycol)
  if (nprow.eq.-1) then
     info = 2010
     call psb_errpush(info,name)
     goto 9999
  else if (npcol /= 1) then
     info = 2030
     int_err(1) = npcol
     call psb_errpush(info,name)
     goto 9999
  endif

  if (.not.psb_is_asb_dec(dscstate)) then 
     info = 600
     int_err(1) = dscstate
     call psb_errpush(info,name)
     goto 9999
  endif

  if (debug) Write (*, *) '   Begin matrix assembly...'

  !check on errors encountered in psdspins

  spstate = a%infoa(psb_state_) 
  if (spstate == psb_spmat_bld_) then 
     !
     ! First case: we come from a fresh build. 
     ! 

     n_row = desc_a%matrix_data(psb_n_row_)
     n_col = desc_a%matrix_data(psb_n_col_)

     !
     ! Second step: handle the local matrix part. 
     !
     iupdup = 0
     if (present(up)) then
        if(up.eq.'Y') then
           iupdup = 4
           iup    = up
        else if (up /= 'N') then
           write(0,*)'Wrong value for update input in ASB...'
           write(0,*)'Changing to default'
           iup = 'N'
        else
           iup = 'N'
        endif
     else
        iup = 'N'
     endif

     if (present(dup)) then
        if((dup.lt.1).or.(dup.gt.3)) then
           write(0,*)'Wrong value for duplicate input in ASB...'
           write(0,*)'Changing to default'
           idup = 1
        else  
           idup = dup
        endif
     else
        idup = 1
     endif
     iupdup = ieor(iupdup,idup)


     a%infoa(psb_upd_)=iupdup
     if (debug) write(0,*)'in ASB',psb_upd_,iupdup

     a%m = n_row
     a%k = n_col

     call psb_sp_clone(a,atemp,info)
     if(info /= no_err) then
        info=4010
        ch_err='psb_sp_clone'
        call psb_errpush(info,name,a_err=ch_err)
        goto 9999
        ! convert to user requested format after the temp copy
     end if
     if (present(afmt)) then
        a%fida = afmt
     else 
        a%fida = '???'
     endif

     !
     ! work area requested must be fixed to
     ! No of Grid'd processes and NNZ+2
     !
     size_req  = max(a%infoa(psb_nnz_),1)+3
     if (debug) write(0,*) 'DCSDP : size_req 1:',size_req
     call psb_cest(a%fida, size_req, ia1_size, ia2_size, aspk_size, iup,info)
     if (info /= no_err) then    
        info=4010
        ch_err='psb_cest'
        call psb_errpush(info,name,a_err=ch_err)
        goto 9999
     endif

     call psb_sp_reall(a,ia1_size,ia2_size,aspk_size,info)
     if (info /= no_err) then    
        info=4010
        ch_err='psb_sp_reall'
        call psb_errpush(info,name,a_err=ch_err)
        goto 9999
     endif

     a%pl(:)  = 0
     a%pr(:)  = 0

     if (debugwrt) then
        iout = 30+myrow
        open(iout)
        call psb_csprt(iout,atemp,head='Input mat')
        close(iout)
     endif

     ! Do the real conversion into the requested storage formatmode
     ! result is put in A
     call psb_csdp(atemp,a,info,ifc=2)

     IF (debug) WRITE (*, *) myrow,'   ASB:  From DCSDP',info,' ',A%FIDA
     if (info /= no_err) then    
        info=4010
        ch_err='psb_csdp'
        call psb_errpush(info,name,a_err=ch_err)
        goto 9999
     endif

     if (debugwrt) then
        iout = 60+myrow
        open(iout)
        call psb_csprt(iout,a,head='Output mat')
        close(iout)
     endif

     call psb_sp_free(atemp,info)


  else if (spstate == psb_spmat_upd_) then
     !
     ! Second  case: we come from an update loop.
     ! 


     ! Right now, almost nothing to be done, but this 
     ! may change in the future
     ! as we revise the implementation of the update routine. 
     call psb_sp_all(atemp,1,info)
     atemp%m=a%m
     atemp%k=a%k
     ! check on allocation
     if (info /= no_err) then    
        info=4010
        ch_err='psb_sp_all'
        call psb_errpush(info,name,a_err=ch_err)
        goto 9999
     endif

     call psb_csdp(atemp,a,info,check='R')
     ! check on error retuned by dcsdp
     if (info /= no_err) then
        info = 4010
        ch_err='psb_csdp90'
        call psb_errpush(info,name,a_err=ch_err)
        goto 9999
     end if

     call psb_sp_free(atemp,info)
     if (info /= no_err) then
        info = 4010
        ch_err='sp_free'
        call psb_errpush(info,name,a_err=ch_err)
        goto 9999
     end if

  else

     info = 600
     call psb_errpush(info,name)
     goto 9999
     if (debug) write(0,*) 'Sparse matrix state:',spstate,psb_spmat_bld_,psb_spmat_upd_

  endif

  call psb_erractionrestore(err_act)
  return

9999 continue
  call psb_erractionrestore(err_act)
  if (err_act.eq.act_abort) then
     call psb_error(icontxt)
     return
  end if
  return

end subroutine psb_dspasb

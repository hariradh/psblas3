!!$ 
!!$              Parallel Sparse BLAS  version 3.0
!!$    (C) Copyright 2006, 2007, 2008, 2009, 2010
!!$                       Salvatore Filippone    University of Rome Tor Vergata
!!$                       Alfredo Buttari        CNRS-IRIT, Toulouse
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
!
! 
!
Subroutine psb_cd_switch_ovl_indxmap(desc,info)

  use psb_sparse_mod, psb_protect_name => psb_cd_switch_ovl_indxmap
  use psi_mod


  Implicit None

  !     .. Array Arguments ..
  Type(psb_desc_type), Intent(inout) :: desc
  integer, intent(out)               :: info

  !     .. Local Scalars ..
  Integer ::  i, j, np, me, mglob, ictxt, n_row, n_col
  integer :: icomm, err_act

  integer, allocatable :: vl(:)
  integer              :: debug_level, debug_unit
  character(len=20)    :: name, ch_err

  name='cd_switch_ovl_indxmap'
  info  = psb_success_
  call psb_erractionsave(err_act)
  debug_unit  = psb_get_debug_unit()
  debug_level = psb_get_debug_level()

  ictxt = psb_cd_get_context(desc)
  icomm = psb_cd_get_mpic(desc)
  Call psb_info(ictxt, me, np)

  If (debug_level >= psb_debug_outer_) &
       & Write(debug_unit,*) me,' ',trim(name),&
       & ': start'

  mglob  = psb_cd_get_global_rows(desc) 
  n_row  = psb_cd_get_local_rows(desc)
  n_col  = psb_cd_get_local_cols(desc)

  Allocate(vl(n_col),stat=info)
  if (info /= psb_success_) then 
    call psb_errpush(psb_err_from_subroutine_,name,a_err='Allocate')
    goto 9999      
  end if

  do i=1,n_col
    vl(i) = i
  end do
  call desc%indxmap%l2g(vl(1:n_col),info)

  write(0,*) 'from l2g' ,info,n_row,n_Col
  if (info /= psb_success_) then
    call psb_errpush(psb_err_from_subroutine_ai_,name,&
         & a_err='map%l2g',i_err=(/info,0,0,0,0/))
    goto 9999
  end if

  call desc%indxmap%free()
  deallocate(desc%indxmap)
  
  if (psb_cd_choose_large_state(ictxt,mglob)) then 
    allocate(psb_hash_map :: desc%indxmap, stat=info)
  else 
    allocate(psb_list_map :: desc%indxmap, stat=info)
  end if
  
  write(0,*) 'from allocate indxmap' ,info
  if (info == psb_success_)&
       & call desc%indxmap%init(ictxt,vl(1:n_row),info)
  write(0,*) 'from indxmap%init' ,info
  if (info == psb_success_) call psb_cd_set_bld(desc,info)
  write(0,*) 'from cd_Set_bld' ,info
  write(0,*) 'into g2l_ins' ,info,vl(n_row+1:n_col)
  if (info == psb_success_) &
       & call  desc%indxmap%g2l_ins(vl(n_row+1:n_col),info)
  write(0,*) 'from g2l_ins' ,info,vl(n_row+1:n_col)
  if (info /= psb_success_) then
    call psb_errpush(psb_err_from_subroutine_ai_,name,&
         & a_err='allocate/init',i_err=(/info,0,0,0,0/))
    goto 9999
  end if
  if (n_row /= desc%indxmap%get_lr()) then 
    write(debug_unit,*) me,' ',trim(name),&
         & ': Local rows mismatch ',n_row,&
         &desc%indxmap%get_lr(),desc%indxmap%get_fmt()
  end if
     
  if (n_col /= desc%indxmap%get_lc()) then 
    write(debug_unit,*) me,' ',trim(name),&
         & ': Local cols mismatch ',n_col,&
         &desc%indxmap%get_lc(),desc%indxmap%get_fmt()
  end if
     
  if (debug_level >= psb_debug_outer_) &
       & write(debug_unit,*) me,' ',trim(name),&
       & ': end',desc%indxmap%get_fmt()

  call psb_erractionrestore(err_act)
  return

9999 continue
  call psb_erractionrestore(err_act)
  if (err_act == psb_act_abort_) then
    call psb_error(ictxt)
    return
  end if
  Return

End Subroutine psb_cd_switch_ovl_indxmap


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
! File: psb_cdfree.f90
!
! Subroutine: psb_cdfree
!   Frees a descriptor data structure.
! 
! Parameters: 
!    desc_a   - type(<psb_desc_type>).         The communication descriptor to be freed.
!    info     - integer.                       Eventually returns an error code.
subroutine psb_cdfree(desc_a,info)
  !...free descriptor structure...
  use psb_descriptor_type
  use psb_const_mod
  use psb_error_mod
  use psb_penv_mod
  implicit none
  !....parameters...
  type(psb_desc_type), intent(inout) :: desc_a
  integer, intent(out)               :: info
  !...locals....
  integer             :: ictxt,np,me, err_act
  character(len=20)   :: name

  if(psb_get_errstatus() /= 0) return 
  info=0
  call psb_erractionsave(err_act)
  name = 'psb_cdfree'


  if (.not.associated(desc_a%matrix_data)) then
    info=295
    call psb_errpush(info,name)
    return
  end if

  ictxt=desc_a%matrix_data(psb_ctxt_)
  deallocate(desc_a%matrix_data)
  call psb_info(ictxt, me, np)
  !     ....verify blacs grid correctness..
  if (np == -1) then
    info = 2010
    call psb_errpush(info,name)
    goto 9999
  endif

  !...deallocate desc_a....
  if(.not.associated(desc_a%loc_to_glob)) then
    info=295
    call psb_errpush(info,name)
    goto 9999
  end if

  !deallocate loc_to_glob  field
  deallocate(desc_a%loc_to_glob,stat=info)
  if (info /= 0) then
    info=2051
    call psb_errpush(info,name)
    goto 9999
  end if

  if (.not.associated(desc_a%glob_to_loc)) then
    info=295
    call psb_errpush(info,name)
    goto 9999
  end if

  !deallocate glob_to_loc field
  deallocate(desc_a%glob_to_loc,stat=info)
  if (info /= 0) then
    info=2052
    call psb_errpush(info,name)
    goto 9999
  end if

  if (.not.associated(desc_a%halo_index)) then
    info=295
    call psb_errpush(info,name)
    goto 9999
  end if

  !deallocate halo_index field
  deallocate(desc_a%halo_index,stat=info)
  if (info /= 0) then
    info=2053
    call psb_errpush(info,name)
    goto 9999
  end if

  if (.not.associated(desc_a%bnd_elem)) then
    info=296
    call psb_errpush(info,name)
    goto 9999
  end if

  !deallocate halo_index field
  deallocate(desc_a%bnd_elem,stat=info)
  if (info /= 0) then
    info=2054
    call psb_errpush(info,name)
    goto 9999
  end if

  if (.not.associated(desc_a%ovrlap_index)) then
    info=295
    call psb_errpush(info,name)
    goto 9999
  end if

  !deallocate ovrlap_index  field
  deallocate(desc_a%ovrlap_index,stat=info)
  if (info /= 0) then
    info=2055
    call psb_errpush(info,name)
    goto 9999
  end if

  !deallocate ovrlap_elem  field
  deallocate(desc_a%ovrlap_elem,stat=info)
  if (info /= 0) then 
    info=2056
    call psb_errpush(info,name)
    goto 9999
  end if

  !deallocate ovrlap_index  field
  deallocate(desc_a%lprm,stat=info)
  if (info /= 0) then 
    info=2057
    call psb_errpush(info,name)
    goto 9999
  end if

  if (associated(desc_a%idx_space)) then 
    deallocate(desc_a%idx_space,stat=info)
    if (info /= 0) then 
      info=2056
      call psb_errpush(info,name)
      goto 9999
    end if
  end if

!!$  if (associated(desc_a%halo_pt)) then 
!!$    deallocate(desc_a%halo_pt,stat=info)
!!$    if (info /= 0) then 
!!$      info=2056
!!$      call psb_errpush(info,name)
!!$      goto 9999
!!$    end if
!!$  end if
!!$
!!$  if (associated(desc_a%ovrlap_pt)) then 
!!$    deallocate(desc_a%ovrlap_pt,stat=info)
!!$    if (info /= 0) then 
!!$      info=2056
!!$      call psb_errpush(info,name)
!!$      goto 9999
!!$    end if
!!$  end if


  call psb_nullify_desc(desc_a)

  call psb_erractionrestore(err_act)
  return

9999 continue
  call psb_erractionrestore(err_act)

  if (err_act == act_ret) then
    return
  else
    call psb_error(ictxt)
  end if
  return

end subroutine psb_cdfree

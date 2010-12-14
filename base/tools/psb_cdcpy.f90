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
  ! Subroutine: psb_cdcpy
  !   Produces a clone of a descriptor.
  ! 
  ! Arguments: 
  !    desc_in  - type(psb_desc_type).         The communication descriptor to be cloned.
  !    desc_out - type(psb_desc_type).         The output communication descriptor.
  !    info     - integer.                       Return code.
subroutine psb_cdcpy(desc_in, desc_out, info)

  use psb_sparse_mod, psb_protect_name => psb_cdcpy

  implicit none
  !....parameters...

  type(psb_desc_type), intent(in)  :: desc_in
  type(psb_desc_type), intent(inout) :: desc_out
  integer, intent(out)             :: info

  !locals
  integer             :: np,me,ictxt, err_act
  integer             :: debug_level, debug_unit
  character(len=20)   :: name

  debug_unit  = psb_get_debug_unit()
  debug_level = psb_get_debug_level()

  if (psb_get_errstatus() /= 0) return 
  info = psb_success_
  call psb_erractionsave(err_act)
  name = 'psb_cdcpy'

  ictxt = psb_cd_get_context(desc_in)

  ! check on blacs grid 
  call psb_info(ictxt, me, np)
  if (debug_level >= psb_debug_ext_) &
       & write(debug_unit,*) me,' ',trim(name),': Entered'
  if (np == -1) then
    info = psb_err_context_error_
    call psb_errpush(info,name)
    goto 9999
  endif

  call psb_safe_ab_cpy(desc_in%matrix_data,desc_out%matrix_data,info)
  if (info == psb_success_) call psb_safe_ab_cpy(desc_in%halo_index,desc_out%halo_index,info)
  if (info == psb_success_) call psb_safe_ab_cpy(desc_in%ext_index,desc_out%ext_index,info)
  if (info == psb_success_) call psb_safe_ab_cpy(desc_in%ovrlap_index,&
       & desc_out%ovrlap_index,info)
  if (info == psb_success_) call psb_safe_ab_cpy(desc_in%bnd_elem,desc_out%bnd_elem,info)
  if (info == psb_success_) call psb_safe_ab_cpy(desc_in%ovrlap_elem,desc_out%ovrlap_elem,info)
  if (info == psb_success_) call psb_safe_ab_cpy(desc_in%ovr_mst_idx,desc_out%ovr_mst_idx,info)
  if (info == psb_success_) call psb_safe_ab_cpy(desc_in%lprm,desc_out%lprm,info)
  if (info == psb_success_) call psb_safe_ab_cpy(desc_in%idx_space,desc_out%idx_space,info)
!!$  if (info == psb_success_) call psb_idxmap_copy(desc_in%idxmap,desc_out%idxmap, info)

  if (allocated(desc_in%indxmap)) then 
    if (allocated(desc_out%indxmap)) then 
      call desc_out%indxmap%free()
      deallocate(desc_out%indxmap)
    end if
    if (info == psb_success_)&
         & allocate(desc_out%indxmap, source=desc_in%indxmap, stat=info) 
  end if

!!$  if (info == psb_success_)   call psb_safe_ab_cpy(desc_in%loc_to_glob,desc_out%loc_to_glob,info)
!!$  if (info == psb_success_)   call psb_safe_ab_cpy(desc_in%glob_to_loc,desc_out%glob_to_loc,info)
!!$  desc_out%hashvsize =   desc_in%hashvsize 
!!$  desc_out%hashvmask =   desc_in%hashvmask
!!$  if (info == psb_success_)   call psb_safe_ab_cpy(desc_in%hashv,desc_out%hashv,info)
!!$  if (info == psb_success_)   call psb_safe_ab_cpy(desc_in%glb_lc,desc_out%glb_lc,info)
!!$  if (info == psb_success_)   call CloneHashTable(desc_in%hash,desc_out%hash,info)

  if (info /= psb_success_) then
    info = psb_err_from_subroutine_
    call psb_errpush(info,name)
    goto 9999
  endif
  if (debug_level >= psb_debug_ext_) &
       & write(debug_unit,*) me,' ',trim(name),': Done'

  call psb_erractionrestore(err_act)
  return

9999 continue
  call psb_erractionrestore(err_act)

  if (err_act == psb_act_ret_) then
    return
  else
    call psb_error(ictxt)
  end if
  return

end subroutine psb_cdcpy

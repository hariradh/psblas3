!!$ 
!!$              Parallel Sparse BLAS  version 2.2
!!$    (C) Copyright 2006/2007/2008
!!$                       Salvatore Filippone    University of Rome Tor Vergata
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
subroutine psb_cprecbld(a,desc_a,p,info,upd)

  use psb_base_mod
  use psb_prec_mod, psb_protect_name => psb_cprecbld
  Implicit None

  type(psb_cspmat_type), target              :: a
  type(psb_desc_type), intent(in), target    :: desc_a
  type(psb_cprec_type),intent(inout)         :: p
  integer, intent(out)                       :: info
  character, intent(in), optional            :: upd


  ! Local scalars
  Integer      :: err, n_row, n_col,ictxt,&
       & me,np,mglob, err_act
  integer      :: int_err(5)
  character    :: upd_

  integer,parameter  :: iroot=psb_root_,iout=60,ilout=40
  character(len=20)   :: name, ch_err

  if(psb_get_errstatus() /= 0) return 
  info=0
  err=0
  call psb_erractionsave(err_act)
  name = 'psb_precbld'

  info = 0
  int_err(1) = 0
  ictxt = psb_cd_get_context(desc_a)

  call psb_info(ictxt, me, np)

  if (present(upd)) then 
    upd_ = psb_toupper(upd)
  else
    upd_='F'
  endif
  if ((upd_ == 'F').or.(upd_ == 'T')) then
    ! ok
  else
    upd_='F'
  endif
  n_row   = psb_cd_get_local_rows(desc_a)
  n_col   = psb_cd_get_local_cols(desc_a)
  mglob   = psb_cd_get_global_rows(desc_a)
  !
  ! Should add check to ensure all procs have the same... 
  !
  ! ALso should define symbolic names for the preconditioners. 
  !

  call psb_check_def(p%iprcparm(psb_p_type_),'base_prec',&
       &  psb_diag_,is_legal_prec)

  call psb_nullify_desc(p%desc_data)

  select case(p%iprcparm(psb_p_type_)) 
  case (psb_noprec_)
    ! Do nothing. 
    call psb_cdcpy(desc_a,p%desc_data,info)
    if(info /= 0) then
      info=4010
      ch_err='psb_cdcpy'
      call psb_errpush(info,name,a_err=ch_err)
      goto 9999
    end if

  case (psb_diag_)

    call psb_diagsc_bld(a,desc_a,p,upd_,info)
    if(info /= 0) then
      info=4010
      ch_err='psb_diagsc_bld'
      call psb_errpush(info,name,a_err=ch_err)
      goto 9999
    end if

  case (psb_bjac_)

    call psb_check_def(p%iprcparm(psb_f_type_),'fact',&
         &  psb_f_ilu_n_,is_legal_ml_fact)

    call psb_bjac_bld(a,desc_a,p,upd_,info)

    if(info /= 0) then
      call psb_errpush(4010,name,a_err='psb_bjac_bld')
      goto 9999
    end if

  case default
    info=4010
    ch_err='Unknown psb_p_type_'
    call psb_errpush(info,name,a_err=ch_err)
    goto 9999

  end select

  call psb_erractionrestore(err_act)
  return

9999 continue
  call psb_erractionrestore(err_act)
  if (err_act == psb_act_abort_) then
    call psb_error()
    return
  end if
  return


end subroutine psb_cprecbld

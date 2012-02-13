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
! package: psb_gen_block_map_mod
!    Defines the GEN_BLOCK_MAP type.
!
!    It is the implementation of the general BLOCK distribution,
!    i.e. process I gets the I-th block of consecutive indices.
!    It needs to store the limits of the owned block, plus the global
!    indices of the local halo.
!    The choice is to store the boundaries of ALL blocks, since in general
!    there will be few processes, compared to indices, so it is possible
!    to answer the ownership question without resorting to data exchange
!    (well, the data exchange is needed but only once at initial allocation
!    time). 
!
!
module psb_gen_block_map_mod
  use psb_const_mod
  use psb_desc_const_mod
  use psb_indx_map_mod
  use psb_hash_mod
  
  type, extends(psb_indx_map) :: psb_gen_block_map
    integer(psb_ipk_) :: min_glob_row   = -1
    integer(psb_ipk_) :: max_glob_row   = -1
    integer(psb_ipk_), allocatable :: loc_to_glob(:), srt_l2g(:,:), vnl(:)
    type(psb_hash_type)  :: hash
  contains

    procedure, pass(idxmap)  :: gen_block_map_init => block_init

    procedure, pass(idxmap)  :: sizeof    => block_sizeof
    procedure, pass(idxmap)  :: asb       => block_asb
    procedure, pass(idxmap)  :: free      => block_free
    procedure, pass(idxmap)  :: clone     => block_clone
    procedure, nopass        :: get_fmt   => block_get_fmt

    procedure, pass(idxmap)  :: l2gs1 => block_l2gs1
    procedure, pass(idxmap)  :: l2gs2 => block_l2gs2
    procedure, pass(idxmap)  :: l2gv1 => block_l2gv1
    procedure, pass(idxmap)  :: l2gv2 => block_l2gv2

    procedure, pass(idxmap)  :: g2ls1 => block_g2ls1
    procedure, pass(idxmap)  :: g2ls2 => block_g2ls2
    procedure, pass(idxmap)  :: g2lv1 => block_g2lv1
    procedure, pass(idxmap)  :: g2lv2 => block_g2lv2

    procedure, pass(idxmap)  :: g2ls1_ins => block_g2ls1_ins
    procedure, pass(idxmap)  :: g2ls2_ins => block_g2ls2_ins
    procedure, pass(idxmap)  :: g2lv1_ins => block_g2lv1_ins
    procedure, pass(idxmap)  :: g2lv2_ins => block_g2lv2_ins

    procedure, pass(idxmap)  :: fnd_owner => block_fnd_owner

  end type psb_gen_block_map

  private ::  block_init, block_sizeof, block_asb, block_free,&
       & block_get_fmt, block_l2gs1, block_l2gs2, block_l2gv1,&
       & block_l2gv2, block_g2ls1, block_g2ls2, block_g2lv1,&
       & block_g2lv2, block_g2ls1_ins, block_g2ls2_ins,&
       & block_g2lv1_ins, block_g2lv2_ins, block_clone


contains

  
  function block_sizeof(idxmap) result(val)
    implicit none 
    class(psb_gen_block_map), intent(in) :: idxmap
    integer(psb_long_int_k_) :: val
    
    val = idxmap%psb_indx_map%sizeof() 
    val = val + 2 * psb_sizeof_int
    if (allocated(idxmap%loc_to_glob)) &
         & val = val + size(idxmap%loc_to_glob)*psb_sizeof_int
    if (allocated(idxmap%srt_l2g)) &
         & val = val + size(idxmap%srt_l2g)*psb_sizeof_int
    if (allocated(idxmap%vnl)) &
         & val = val + size(idxmap%vnl)*psb_sizeof_int
    val = val + psb_sizeof(idxmap%hash)
  end function block_sizeof


  subroutine block_free(idxmap)
    implicit none 
    class(psb_gen_block_map), intent(inout) :: idxmap
    integer(psb_ipk_) :: info
    if (allocated(idxmap%loc_to_glob)) &
         & deallocate(idxmap%loc_to_glob)
    if (allocated(idxmap%srt_l2g)) &
         & deallocate(idxmap%srt_l2g)

    if (allocated(idxmap%srt_l2g)) &
         & deallocate(idxmap%vnl)
    call psb_free(idxmap%hash,info)
    call idxmap%psb_indx_map%free()

  end subroutine block_free


  subroutine block_l2gs1(idx,idxmap,info,mask,owned)
    implicit none 
    class(psb_gen_block_map), intent(in) :: idxmap
    integer, intent(inout) :: idx
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask
    logical, intent(in), optional :: owned
    integer  :: idxv(1)
    info = 0
    if (present(mask)) then 
      if (.not.mask) return
    end if

    idxv(1) = idx
    call idxmap%l2g(idxv,info,owned=owned)
    idx = idxv(1)

  end subroutine block_l2gs1

  subroutine block_l2gs2(idxin,idxout,idxmap,info,mask,owned)
    implicit none 
    class(psb_gen_block_map), intent(in) :: idxmap
    integer, intent(in)    :: idxin
    integer, intent(out)   :: idxout
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask
    logical, intent(in), optional :: owned

    idxout = idxin
    call idxmap%l2g(idxout,info,mask,owned)
    
  end subroutine block_l2gs2


  subroutine block_l2gv1(idx,idxmap,info,mask,owned)
    implicit none 
    class(psb_gen_block_map), intent(in) :: idxmap
    integer, intent(inout) :: idx(:)
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask(:)
    logical, intent(in), optional :: owned
    integer :: i
    logical :: owned_
    info = 0

    if (present(mask)) then 
      if (size(mask) < size(idx)) then 
        info = -1
        return
      end if
    end if
    if (present(owned)) then 
      owned_ = owned
    else
      owned_ = .false.
    end if

    if (present(mask)) then 

      do i=1, size(idx)
        if (mask(i)) then 
          if ((1<=idx(i)).and.(idx(i) <= idxmap%local_rows)) then
            idx(i) = idxmap%min_glob_row + idx(i) - 1
          else if ((idxmap%local_rows < idx(i)).and.(idx(i) <= idxmap%local_cols)&
               & .and.(.not.owned_)) then
            idx(i) = idxmap%loc_to_glob(idx(i)-idxmap%local_rows)
          else 
            idx(i) = -1
            info = -1
          end if
        end if
      end do

    else  if (.not.present(mask)) then 

      do i=1, size(idx)
        if ((1<=idx(i)).and.(idx(i) <= idxmap%local_rows)) then
          idx(i) = idxmap%min_glob_row + idx(i) - 1
        else if ((idxmap%local_rows < idx(i)).and.(idx(i) <= idxmap%local_cols)&
             & .and.(.not.owned_)) then
          idx(i) = idxmap%loc_to_glob(idx(i)-idxmap%local_rows)
        else 
          idx(i) = -1
          info = -1
        end if
      end do

    end if

  end subroutine block_l2gv1

  subroutine block_l2gv2(idxin,idxout,idxmap,info,mask,owned)
    implicit none 
    class(psb_gen_block_map), intent(in) :: idxmap
    integer, intent(in)    :: idxin(:)
    integer, intent(out)   :: idxout(:)
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask(:)
    logical, intent(in), optional :: owned
    integer :: is, im
    
    is = size(idxin)
    im = min(is,size(idxout))
    idxout(1:im) = idxin(1:im)
    call idxmap%l2g(idxout(1:im),info,mask,owned)
    if (is > im) then 
      info = -3 
    end if

  end subroutine block_l2gv2


  subroutine block_g2ls1(idx,idxmap,info,mask,owned)
    implicit none 
    class(psb_gen_block_map), intent(in) :: idxmap
    integer, intent(inout) :: idx
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask
    logical, intent(in), optional :: owned
    integer :: idxv(1)
    info = 0

    if (present(mask)) then 
      if (.not.mask) return
    end if
    
    idxv(1) = idx 
    call idxmap%g2l(idxv,info,owned=owned)
    idx = idxv(1) 
      
  end subroutine block_g2ls1

  subroutine block_g2ls2(idxin,idxout,idxmap,info,mask,owned)
    implicit none 
    class(psb_gen_block_map), intent(in) :: idxmap
    integer, intent(in)    :: idxin
    integer, intent(out)   :: idxout
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask
    logical, intent(in), optional :: owned

    idxout = idxin
    call idxmap%g2l(idxout,info,mask,owned)
    
  end subroutine block_g2ls2


  subroutine block_g2lv1(idx,idxmap,info,mask,owned)
    use psb_penv_mod
    use psb_sort_mod
    implicit none 
    class(psb_gen_block_map), intent(in) :: idxmap
    integer, intent(inout) :: idx(:)
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask(:)
    logical, intent(in), optional :: owned
    integer(psb_ipk_) :: i, nv, is, ip, lip 
    integer(psb_ipk_) :: ictxt, iam, np
    logical :: owned_

    info = 0
    ictxt = idxmap%get_ctxt()
    call psb_info(ictxt,iam,np) 

    if (present(mask)) then 
      if (size(mask) < size(idx)) then 
!!$        write(0,*) 'Block g2l: size of mask', size(mask),size(idx)
        info = -1
        return
      end if
    end if
    if (present(owned)) then 
      owned_ = owned
    else
      owned_ = .false.
    end if

    is = size(idx)
    if (present(mask)) then 

      if (idxmap%is_asb()) then 
        do i=1, is
          if (mask(i)) then 
            if ((idxmap%min_glob_row <= idx(i)).and.(idx(i) <= idxmap%max_glob_row)) then
              idx(i) = idx(i) - idxmap%min_glob_row + 1
            else if ((1<= idx(i)).and.(idx(i) <= idxmap%global_rows)&
                 &.and.(.not.owned_)) then
              nv  = size(idxmap%srt_l2g,1)
              idx(i) = psb_ibsrch(idx(i),nv,idxmap%srt_l2g(:,1))
              if (idx(i) > 0) idx(i) = idxmap%srt_l2g(idx(i),2)+idxmap%local_rows
            else 
              idx(i) = -1
            end if
          end if
        end do
      else if (idxmap%is_valid()) then 
        do i=1,is
          if (mask(i)) then 
            if ((idxmap%min_glob_row <= idx(i)).and.(idx(i) <= idxmap%max_glob_row)) then
              idx(i) = idx(i) - idxmap%min_glob_row + 1
            else if ((1<= idx(i)).and.(idx(i) <= idxmap%global_rows)&
                 &.and.(.not.owned_)) then
              ip = idx(i)
              call psb_hash_searchkey(ip,lip,idxmap%hash,info)
              if (lip > 0) idx(i) = lip + idxmap%local_rows
            else 
              idx(i) = -1
            end if
          end if
        end do
      else 
!!$        write(0,*) 'Block status: invalid ',idxmap%get_state()
        idx(1:is) = -1
        info = -1
      end if

    else  if (.not.present(mask)) then 

      if (idxmap%is_asb()) then 
        do i=1, is
          if ((idxmap%min_glob_row <= idx(i)).and.(idx(i) <= idxmap%max_glob_row)) then
            idx(i) = idx(i) - idxmap%min_glob_row + 1
          else if ((1<= idx(i)).and.(idx(i) <= idxmap%global_rows)&
               &.and.(.not.owned_)) then
            nv  = size(idxmap%srt_l2g,1)
            idx(i) = psb_ibsrch(idx(i),nv,idxmap%srt_l2g(:,1))
            if (idx(i) > 0) idx(i) = idxmap%srt_l2g(idx(i),2)+idxmap%local_rows
          else 
            idx(i) = -1
          end if
        end do

      else if (idxmap%is_valid()) then 
        do i=1,is
          if ((idxmap%min_glob_row <= idx(i)).and.(idx(i) <= idxmap%max_glob_row)) then
            idx(i) = idx(i) - idxmap%min_glob_row + 1
          else if ((1<= idx(i)).and.(idx(i) <= idxmap%global_rows)&
               &.and.(.not.owned_)) then
            ip = idx(i)
            call psb_hash_searchkey(ip,lip,idxmap%hash,info)
            if (lip > 0) idx(i) = lip + idxmap%local_rows
          else 
            idx(i) = -1
          end if
        end do
      else 
!!$        write(0,*) 'Block status: invalid ',idxmap%get_state()
        idx(1:is) = -1
        info = -1
      end if

    end if

  end subroutine block_g2lv1

  subroutine block_g2lv2(idxin,idxout,idxmap,info,mask,owned)
    implicit none 
    class(psb_gen_block_map), intent(in) :: idxmap
    integer, intent(in)    :: idxin(:)
    integer, intent(out)   :: idxout(:)
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask(:)
    logical, intent(in), optional :: owned

    integer :: is, im
    
    is = size(idxin)
    im = min(is,size(idxout))
    idxout(1:im) = idxin(1:im)
    call idxmap%g2l(idxout(1:im),info,mask,owned)
    if (is > im) info = -3 

  end subroutine block_g2lv2



  subroutine block_g2ls1_ins(idx,idxmap,info,mask)
    use psb_realloc_mod
    use psb_sort_mod
    implicit none 
    class(psb_gen_block_map), intent(inout) :: idxmap
    integer, intent(inout) :: idx
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask
    
    integer :: idxv(1)

    info = 0
    if (present(mask)) then 
      if (.not.mask) return
    end if
    idxv(1) = idx
    call idxmap%g2l_ins(idxv,info)
    idx = idxv(1) 

  end subroutine block_g2ls1_ins

  subroutine block_g2ls2_ins(idxin,idxout,idxmap,info,mask)
    implicit none 
    class(psb_gen_block_map), intent(inout) :: idxmap
    integer, intent(in)    :: idxin
    integer, intent(out)   :: idxout
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask
    
    idxout = idxin
    call idxmap%g2l_ins(idxout,info)
    
  end subroutine block_g2ls2_ins


  subroutine block_g2lv1_ins(idx,idxmap,info,mask)
    use psb_realloc_mod
    use psb_sort_mod
    implicit none 
    class(psb_gen_block_map), intent(inout) :: idxmap
    integer, intent(inout) :: idx(:)
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask(:)
    integer(psb_ipk_) :: i, nv, is, ix
    integer(psb_ipk_) :: ip, lip, nxt


    info = 0
    is = size(idx)

    if (present(mask)) then 
      if (size(mask) < size(idx)) then 
        info = -1
        return
      end if
    end if


    if (idxmap%is_asb()) then 
      ! State is wrong for this one ! 
      idx = -1
      info = -1

    else if (idxmap%is_valid()) then 

      if (present(mask)) then 
        do i=1, is
          if (mask(i)) then 
            if ((idxmap%min_glob_row <= idx(i)).and.(idx(i) <= idxmap%max_glob_row)) then
              idx(i) = idx(i) - idxmap%min_glob_row + 1
            else if ((1<= idx(i)).and.(idx(i) <= idxmap%global_rows)) then
              nv  = idxmap%local_cols-idxmap%local_rows
              nxt = nv + 1 
              ip = idx(i) 
              call psb_hash_searchinskey(ip,lip,nxt,idxmap%hash,info)
              if (info >= 0) then 
                if (lip == nxt) then 
                  ! We have added one item
                  call psb_ensure_size(nxt,idxmap%loc_to_glob,info,addsz=500)
                  if (info /= 0) then 
                    info = -4
                    return
                  end if
                  idxmap%local_cols       = nxt + idxmap%local_rows
                  idxmap%loc_to_glob(nxt) = idx(i)
                end if
                info = psb_success_
              else
                info = -5
                return
              end if
              idx(i)  = lip + idxmap%local_rows
            else 
              idx(i) = -1
              info = -1
            end if
          end if
        end do

      else if (.not.present(mask)) then 

        do i=1, is

          if ((idxmap%min_glob_row <= idx(i)).and.(idx(i) <= idxmap%max_glob_row)) then
            idx(i) = idx(i) - idxmap%min_glob_row + 1
          else if ((1<= idx(i)).and.(idx(i) <= idxmap%global_rows)) then
            nv  = idxmap%local_cols-idxmap%local_rows
            nxt = nv + 1 
            ip = idx(i) 
            call psb_hash_searchinskey(ip,lip,nxt,idxmap%hash,info)

            if (info >= 0) then 
              if (lip == nxt) then 
                ! We have added one item
                call psb_ensure_size(nxt,idxmap%loc_to_glob,info,addsz=500)
                if (info /= 0) then 
                  info = -4
                  return
                end if
                idxmap%local_cols       = nxt + idxmap%local_rows
                idxmap%loc_to_glob(nxt) = idx(i)
              end if
              info = psb_success_
            else
              info = -5
              return
            end if
            idx(i)  = lip + idxmap%local_rows
          else 
            idx(i) = -1
            info = -1
          end if
        end do
      end if

    else 
      idx = -1
      info = -1
    end if

  end subroutine block_g2lv1_ins

  subroutine block_g2lv2_ins(idxin,idxout,idxmap,info,mask)
    implicit none 
    class(psb_gen_block_map), intent(inout) :: idxmap
    integer(psb_ipk_), intent(in)    :: idxin(:)
    integer(psb_ipk_), intent(out)   :: idxout(:)
    integer(psb_ipk_), intent(out)   :: info 
    logical, intent(in), optional :: mask(:)
    integer :: is, im
    
    is = size(idxin)
    im = min(is,size(idxout))
    idxout(1:im) = idxin(1:im)
    call idxmap%g2l_ins(idxout(1:im),info,mask)
    if (is > im) then 
!!$      write(0,*) 'g2lv2_ins err -3'
      info = -3 
    end if

  end subroutine block_g2lv2_ins

  subroutine block_fnd_owner(idx,iprc,idxmap,info)
    use psb_penv_mod
    use psb_sort_mod
    implicit none 
    integer, intent(in) :: idx(:)
    integer, allocatable, intent(out) ::  iprc(:)
    class(psb_gen_block_map), intent(in) :: idxmap
    integer, intent(out) :: info
    integer :: ictxt, iam, np, nv, ip, i
    
    ictxt = idxmap%get_ctxt()
    call psb_info(ictxt,iam,np)
    nv = size(idx)
    allocate(iprc(nv),stat=info) 
    if (info /= 0) then 
!!$      write(0,*) 'Memory allocation failure in repl_map_fnd-owner'
      return
    end if
    do i=1, nv 
      ip = psb_iblsrch(idx(i)-1,np+1,idxmap%vnl)
      iprc(i) = ip - 1
    end do

  end subroutine block_fnd_owner



  subroutine block_init(idxmap,ictxt,nl,info)
    use psb_penv_mod
    use psb_error_mod
    implicit none 
    class(psb_gen_block_map), intent(inout) :: idxmap
    integer, intent(in)  :: ictxt, nl
    integer, intent(out) :: info
    !  To be implemented
    integer :: iam, np, i, ntot
    integer, allocatable :: vnl(:)

    info = 0
    call psb_info(ictxt,iam,np) 
    if (np < 0) then 
      write(psb_err_unit,*) 'Invalid ictxt:',ictxt
      info = -1
      return
    end if
    allocate(vnl(0:np),stat=info)
    if (info /= 0)  then
      info = -2
      return
    end if
    
    vnl(:)   = 0
    vnl(iam) = nl
    call psb_sum(ictxt,vnl)
    ntot = sum(vnl)
    vnl(1:np) = vnl(0:np-1)
    vnl(0) = 0
    do i=1,np
      vnl(i) = vnl(i) + vnl(i-1)
    end do
    if (ntot /= vnl(np)) then 
!!$      write(0,*) ' Mismatch in block_init ',ntot,vnl(np)
    end if
    
    idxmap%global_rows  = ntot
    idxmap%global_cols  = ntot
    idxmap%local_rows   = nl
    idxmap%local_cols   = nl
    idxmap%ictxt        = ictxt
    idxmap%state        = psb_desc_bld_
    call psb_get_mpicomm(ictxt,idxmap%mpic)
    idxmap%min_glob_row = vnl(iam)+1
    idxmap%max_glob_row = vnl(iam+1) 
    call move_alloc(vnl,idxmap%vnl)
    allocate(idxmap%loc_to_glob(nl),stat=info) 
    if (info /= 0)  then
      info = -2
      return
    end if
    call psb_hash_init(nl,idxmap%hash,info)
    call idxmap%set_state(psb_desc_bld_)
    
  end subroutine block_init


  subroutine block_asb(idxmap,info)
    use psb_penv_mod
    use psb_error_mod
    use psb_realloc_mod
    use psb_sort_mod
    implicit none 
    class(psb_gen_block_map), intent(inout) :: idxmap
    integer, intent(out) :: info
    
    integer :: nhal, ictxt, iam, np 
    
    info = 0 
    ictxt = idxmap%get_ctxt()
    call psb_info(ictxt,iam,np)

    nhal = idxmap%local_cols-idxmap%local_rows

    call psb_realloc(nhal,idxmap%loc_to_glob,info)
    call psb_realloc(nhal,2,idxmap%srt_l2g,info)
    idxmap%srt_l2g(1:nhal,1) = idxmap%loc_to_glob(1:nhal)

    call psb_msort(idxmap%srt_l2g(:,1),&
         & ix=idxmap%srt_l2g(:,2),dir=psb_sort_up_)

    call psb_free(idxmap%hash,info)
    call idxmap%set_state(psb_desc_asb_)
    
  end subroutine block_asb

  function block_get_fmt() result(res)
    implicit none 
    character(len=5) :: res
    res = 'BLOCK'
  end function block_get_fmt


  subroutine block_clone(idxmap,outmap,info)
    use psb_penv_mod
    use psb_error_mod
    use psb_realloc_mod
    implicit none 
    class(psb_gen_block_map), intent(in)    :: idxmap
    class(psb_indx_map), allocatable, intent(out) :: outmap
    integer, intent(out) :: info
    Integer :: err_act
    character(len=20)  :: name='block_clone'
    logical, parameter :: debug=.false.

    info = psb_success_
    call psb_get_erraction(err_act)
    if (allocated(outmap)) then 
      write(0,*) 'Error: should not be allocated on input'
      info = -87
      goto 9999
    end if
    
    allocate(psb_gen_block_map :: outmap, stat=info) 
    if (info /= psb_success_) then 
      info = psb_err_alloc_dealloc_
      call psb_errpush(info,name)
      goto 9999
    end if

    select type (outmap)
    type is (psb_gen_block_map) 
      if (info == psb_success_) then 
        outmap%psb_indx_map = idxmap%psb_indx_map
        outmap%min_glob_row = idxmap%min_glob_row
        outmap%max_glob_row = idxmap%max_glob_row
      end if
      if (info == psb_success_)&
           &  call psb_safe_ab_cpy(idxmap%loc_to_glob,outmap%loc_to_glob,info)
      if (info == psb_success_)&
           &  call psb_safe_ab_cpy(idxmap%vnl,outmap%vnl,info)
      if (info == psb_success_)&
           &  call psb_safe_ab_cpy(idxmap%srt_l2g,outmap%srt_l2g,info)
      if (info == psb_success_)&
           &  call psb_hash_copy(idxmap%hash,outmap%hash,info)

    class default
      ! This should be impossible 
      info = -1
    end select
      
    if (info /= psb_success_) then 
      info = psb_err_from_subroutine_
      call psb_errpush(info,name)
      goto 9999
    end if
    call psb_erractionrestore(err_act)
    return

9999 continue
    call psb_erractionrestore(err_act)
    if (err_act /= psb_act_ret_) then
      call psb_error()
    end if
    return
  end subroutine block_clone

end module psb_gen_block_map_mod

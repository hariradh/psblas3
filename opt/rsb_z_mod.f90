module rsb_z_mod
  use iso_c_binding

! module constants:

interface
integer(c_int) function &
  &rsb_perror&
  &(errval)&
  &bind(c,name='rsb_perror')
use iso_c_binding
 integer(c_int), value  :: errval
 end function rsb_perror
end interface

interface
integer(c_int) function &
  &rsb_init&
  &(io)&
  &bind(c,name='rsb_init')
use iso_c_binding
 type(c_ptr), value  :: io
 end function rsb_init
end interface

interface
integer(c_int) function &
  &rsb_reinit&
  &(io)&
  &bind(c,name='rsb_reinit')
use iso_c_binding
 type(c_ptr), value  :: io
 end function rsb_reinit
end interface

interface
integer(c_int) function &
  &rsb_was_initialized&
  &()&
  &bind(c,name='rsb_was_initialized')
use iso_c_binding
 end function rsb_was_initialized
end interface

interface
integer(c_int) function &
  &rsb_exit&
  &()&
  &bind(c,name='rsb_exit')
use iso_c_binding
 end function rsb_exit
end interface

interface
integer(c_int) function &
  &rsb_meminfo&
  &()&
  &bind(c,name='rsb_meminfo')
use iso_c_binding
 end function rsb_meminfo
end interface

interface
integer(c_int) function &
  &rsb_check_leak&
  &()&
  &bind(c,name='rsb_check_leak')
use iso_c_binding
 end function rsb_check_leak
end interface

interface
type(c_ptr) function &
  &rsb_allocate_rsb_sparse_matrix_from_csr_const&
  &(VA,IA,JA,nnz,typecode,m,k,Mb,Kb,flags,errvalp)&
  &bind(c,name='rsb_allocate_rsb_sparse_matrix_from_csr_const')
use iso_c_binding
 complex(c_double) :: VA(*)
 integer(c_int) :: IA(*)
 integer(c_int) :: JA(*)
 integer(c_int), value  :: nnz
 integer(c_int), value  :: typecode
 integer(c_int), value  :: m
 integer(c_int), value  :: k
 integer(c_int), value  :: Mb
 integer(c_int), value  :: Kb
 integer(c_int), value  :: flags
 integer(c_int) :: errvalp
 end function rsb_allocate_rsb_sparse_matrix_from_csr_const
end interface

interface
type(c_ptr) function &
  &rsb_allocate_rsb_sparse_matrix_from_csr_inplace&
  &(VA,IA,JA,nnz,typecode,m,k,Mb,Kb,flags,errvalp)&
  &bind(c,name='rsb_allocate_rsb_sparse_matrix_from_csr_inplace')
use iso_c_binding
 complex(c_double) :: VA(*)
 integer(c_int) :: IA(*)
 integer(c_int) :: JA(*)
 integer(c_int), value  :: nnz
 integer(c_int), value  :: typecode
 integer(c_int), value  :: m
 integer(c_int), value  :: k
 integer(c_int), value  :: Mb
 integer(c_int), value  :: Kb
 integer(c_int), value  :: flags
 integer(c_int) :: errvalp
 end function rsb_allocate_rsb_sparse_matrix_from_csr_inplace
end interface

interface
type(c_ptr) function &
  &rsb_allocate_rsb_sparse_matrix_const&
  &(VA,IA,JA,nnz,typecode,m,k,Mb,Kb,flags,errvalp)&
  &bind(c,name='rsb_allocate_rsb_sparse_matrix_const')
use iso_c_binding
 complex(c_double) :: VA(*)
 integer(c_int) :: IA(*)
 integer(c_int) :: JA(*)
 integer(c_int), value  :: nnz
 integer(c_int), value  :: typecode
 integer(c_int), value  :: m
 integer(c_int), value  :: k
 integer(c_int), value  :: Mb
 integer(c_int), value  :: Kb
 integer(c_int), value  :: flags
 integer(c_int) :: errvalp
 end function rsb_allocate_rsb_sparse_matrix_const
end interface

interface
type(c_ptr) function &
  &rsb_allocate_rsb_sparse_matrix_inplace&
  &(VA,IA,JA,nnz,typecode,m,k,Mb,Kb,flags,errvalp)&
  &bind(c,name='rsb_allocate_rsb_sparse_matrix_inplace')
use iso_c_binding
 complex(c_double) :: VA(*)
 integer(c_int) :: IA(*)
 integer(c_int) :: JA(*)
 integer(c_int), value  :: nnz
 integer(c_int), value  :: typecode
 integer(c_int), value  :: m
 integer(c_int), value  :: k
 integer(c_int), value  :: Mb
 integer(c_int), value  :: Kb
 integer(c_int), value  :: flags
 integer(c_int) :: errvalp
 end function rsb_allocate_rsb_sparse_matrix_inplace
end interface

interface
type(c_ptr) function &
  &rsb_free_sparse_matrix&
  &(matrix)&
  &bind(c,name='rsb_free_sparse_matrix')
use iso_c_binding
 type(c_ptr), value  :: matrix
 end function rsb_free_sparse_matrix
end interface

interface
type(c_ptr) function &
  &rsb_clone&
  &(matrix)&
  &bind(c,name='rsb_clone')
use iso_c_binding
 type(c_ptr), value  :: matrix
 end function rsb_clone
end interface

interface
integer(c_int) function &
  &rsb_spmv&
  &(transa,alphap,matrix,x,incx,betap,y,incy)&
  &bind(c,name='rsb_spmv')
use iso_c_binding
 integer(c_int), value  :: transa
 complex(c_double) :: alphap
 type(c_ptr), value  :: matrix
 complex(c_double) :: x(*)
 integer(c_int), value  :: incx
 complex(c_double) :: betap
 complex(c_double) :: y(*)
 integer(c_int), value  :: incy
 end function rsb_spmv
end interface

interface
integer(c_int) function &
  &rsb_spmv_nt&
  &(alphap,matrix,x1,x2,incx,betap,y1,y2,incy)&
  &bind(c,name='rsb_spmv_nt')
use iso_c_binding
 complex(c_double) :: alphap
 type(c_ptr), value  :: matrix
 complex(c_double) :: x1(*)
 complex(c_double) :: x2(*)
 integer(c_int), value  :: incx
 complex(c_double) :: betap
 complex(c_double) :: y1(*)
 complex(c_double) :: y2(*)
 integer(c_int), value  :: incy
 end function rsb_spmv_nt
end interface

interface
integer(c_int) function &
  &rsb_spmv_ata&
  &(alphap,matrix,x,incx,betap,y,incy)&
  &bind(c,name='rsb_spmv_ata')
use iso_c_binding
 complex(c_double) :: alphap
 type(c_ptr), value  :: matrix
 complex(c_double) :: x(*)
 integer(c_int), value  :: incx
 complex(c_double) :: betap
 complex(c_double) :: y(*)
 integer(c_int), value  :: incy
 end function rsb_spmv_ata
end interface

interface
integer(c_int) function &
  &rsb_spmv_power&
  &(transa,alphap,matrix,exp,x,incx,betap,y,incy)&
  &bind(c,name='rsb_spmv_power')
use iso_c_binding
 integer(c_int), value  :: transa
 complex(c_double) :: alphap
 type(c_ptr), value  :: matrix
 integer(c_int), value  :: exp
 complex(c_double) :: x(*)
 integer(c_int), value  :: incx
 complex(c_double) :: betap
 complex(c_double) :: y(*)
 integer(c_int), value  :: incy
 end function rsb_spmv_power
end interface

interface
integer(c_int) function &
  &rsb_spmm&
  &(transa,alphap,matrix,nrhs,order,b,ldb,betap,c,ldc)&
  &bind(c,name='rsb_spmm')
use iso_c_binding
 integer(c_int), value  :: transa
 complex(c_double) :: alphap
 type(c_ptr), value  :: matrix
 integer(c_int), value  :: nrhs
 integer(c_int), value  :: order
 complex(c_double) :: b(*)
 integer(c_int), value  :: ldb
 complex(c_double) :: betap
 complex(c_double) :: c(*)
 integer(c_int), value  :: ldc
 end function rsb_spmm
end interface

interface
integer(c_int) function &
  &rsb_spsv&
  &(trans,alphap,matrix,x,incx,y,incy)&
  &bind(c,name='rsb_spsv')
use iso_c_binding
 integer(c_int), value  :: trans
 complex(c_double) :: alphap
 type(c_ptr), value  :: matrix
 complex(c_double) :: x(*)
 integer(c_int), value  :: incx
 complex(c_double) :: y(*)
 integer(c_int), value  :: incy
 end function rsb_spsv
end interface

interface
integer(c_int) function &
  &rsb_spsm&
  &(trans,alphap,matrix,nrhs,order,betap,b,ldb,c,ldc)&
  &bind(c,name='rsb_spsm')
use iso_c_binding
 integer(c_int), value  :: trans
 complex(c_double) :: alphap
 type(c_ptr), value  :: matrix
 integer(c_int), value  :: nrhs
 integer(c_int), value  :: order
 complex(c_double) :: betap
 complex(c_double) :: b(*)
 integer(c_int), value  :: ldb
 complex(c_double) :: c(*)
 integer(c_int), value  :: ldc
 end function rsb_spsm
end interface

interface
integer(c_int) function &
  &rsb_infinity_norm&
  &(matrix,infinity_norm,transa)&
  &bind(c,name='rsb_infinity_norm')
use iso_c_binding
 type(c_ptr), value  :: matrix
 complex(c_double) :: infinity_norm(*)
 integer(c_int), value  :: transa
 end function rsb_infinity_norm
end interface

interface
integer(c_int) function &
  &rsb_one_norm&
  &(matrix,one_norm,transa)&
  &bind(c,name='rsb_one_norm')
use iso_c_binding
 type(c_ptr), value  :: matrix
 complex(c_double) :: one_norm(*)
 integer(c_int), value  :: transa
 end function rsb_one_norm
end interface

interface
integer(c_int) function &
  &rsb_rows_sums&
  &(matrix,d)&
  &bind(c,name='rsb_rows_sums')
use iso_c_binding
 type(c_ptr), value  :: matrix
 complex(c_double) :: d(*)
 end function rsb_rows_sums
end interface

interface
integer(c_int) function &
  &rsb_columns_sums&
  &(matrix,d)&
  &bind(c,name='rsb_columns_sums')
use iso_c_binding
 type(c_ptr), value  :: matrix
 complex(c_double) :: d(*)
 end function rsb_columns_sums
end interface

interface
integer(c_int) function &
  &rsb_absolute_rows_sums&
  &(matrix,d)&
  &bind(c,name='rsb_absolute_rows_sums')
use iso_c_binding
 type(c_ptr), value  :: matrix
 complex(c_double) :: d(*)
 end function rsb_absolute_rows_sums
end interface

interface
integer(c_int) function &
  &rsb_absolute_columns_sums&
  &(matrix,d)&
  &bind(c,name='rsb_absolute_columns_sums')
use iso_c_binding
 type(c_ptr), value  :: matrix
 complex(c_double) :: d(*)
 end function rsb_absolute_columns_sums
end interface

interface
integer(c_int) function &
  &rsb_matrix_add_to_dense&
  &(matrixa,alphap,transa,matrixb,ldb,nr,nc,rowmajor)&
  &bind(c,name='rsb_matrix_add_to_dense')
use iso_c_binding
 type(c_ptr), value  :: matrixa
 complex(c_double) :: alphap
 integer(c_int), value  :: transa
 type(c_ptr), value  :: matrixb
 integer(c_int), value  :: ldb
 integer(c_int), value  :: nr
 integer(c_int), value  :: nc
 integer(c_int), value  :: rowmajor
 end function rsb_matrix_add_to_dense
end interface

interface
type(c_ptr) function &
  &rsb_matrix_sum&
  &(transa,alphap,matrixa,transb,betap,matrixb,errvalp)&
  &bind(c,name='rsb_matrix_sum')
use iso_c_binding
 integer(c_int), value  :: transa
 complex(c_double) :: alphap
 type(c_ptr), value  :: matrixa
 integer(c_int), value  :: transb
 complex(c_double) :: betap
 type(c_ptr), value  :: matrixb
 integer(c_int) :: errvalp
 end function rsb_matrix_sum
end interface

interface
type(c_ptr) function &
  &rsb_matrix_mul&
  &(transa,alphap,matrixa,transb,betap,matrixb,errvalp)&
  &bind(c,name='rsb_matrix_mul')
use iso_c_binding
 integer(c_int), value  :: transa
 complex(c_double) :: alphap
 type(c_ptr), value  :: matrixa
 integer(c_int), value  :: transb
 complex(c_double) :: betap
 type(c_ptr), value  :: matrixb
 integer(c_int) :: errvalp
 end function rsb_matrix_mul
end interface

interface
integer(c_int) function &
  &rsb_util_sort_row_major&
  &(VA,IA,JA,nnz,m,k,typecode,flags)&
  &bind(c,name='rsb_util_sort_row_major')
use iso_c_binding
 complex(c_double) :: VA(*)
 integer(c_int) :: IA(*)
 integer(c_int) :: JA(*)
 integer(c_int), value  :: nnz
 integer(c_int), value  :: m
 integer(c_int), value  :: k
 integer(c_int), value  :: typecode
 integer(c_int), value  :: flags
 end function rsb_util_sort_row_major
end interface

interface
integer(c_int) function &
  &rsb_util_sort_column_major&
  &(VA,IA,JA,nnz,m,k,typecode,flags)&
  &bind(c,name='rsb_util_sort_column_major')
use iso_c_binding
 complex(c_double) :: VA(*)
 integer(c_int) :: IA(*)
 integer(c_int) :: JA(*)
 integer(c_int), value  :: nnz
 integer(c_int), value  :: m
 integer(c_int), value  :: k
 integer(c_int), value  :: typecode
 integer(c_int), value  :: flags
 end function rsb_util_sort_column_major
end interface

interface
integer(c_int) function &
  &rsb_switch_rsb_matrix_to_coo_unsorted&
  &(matrix,VAP,IAP,JAP,flags)&
  &bind(c,name='rsb_switch_rsb_matrix_to_coo_unsorted')
use iso_c_binding
 type(c_ptr), value  :: matrix
 type(c_ptr), value  :: VAP
 integer(c_int) :: IAP(*)
 integer(c_int) :: JAP(*)
 integer(c_int), value  :: flags
 end function rsb_switch_rsb_matrix_to_coo_unsorted
end interface

interface
integer(c_int) function &
  &rsb_switch_rsb_matrix_to_coo_sorted&
  &(matrix,VAP,IAP,JAP,flags)&
  &bind(c,name='rsb_switch_rsb_matrix_to_coo_sorted')
use iso_c_binding
 type(c_ptr), value  :: matrix
 type(c_ptr), value  :: VAP
 integer(c_int) :: IAP(*)
 integer(c_int) :: JAP(*)
 integer(c_int), value  :: flags
 end function rsb_switch_rsb_matrix_to_coo_sorted
end interface

interface
integer(c_int) function &
  &rsb_switch_rsb_matrix_to_csr_sorted&
  &(matrix,VAP,IAP,JAP,flags)&
  &bind(c,name='rsb_switch_rsb_matrix_to_csr_sorted')
use iso_c_binding
 type(c_ptr), value  :: matrix
 type(c_ptr), value  :: VAP
 integer(c_int) :: IAP(*)
 integer(c_int) :: JAP(*)
 integer(c_int), value  :: flags
 end function rsb_switch_rsb_matrix_to_csr_sorted
end interface

interface
integer(c_int) function &
  &rsb_get_coo&
  &(matrix,VA,IA,JA,flags)&
  &bind(c,name='rsb_get_coo')
use iso_c_binding
 type(c_ptr), value  :: matrix
 complex(c_double) :: VA(*)
 integer(c_int) :: IA(*)
 integer(c_int) :: JA(*)
 integer(c_int), value  :: flags
 end function rsb_get_coo
end interface

interface
integer(c_int) function &
  &rsb_get_csr&
  &(matrix,VA,RP,JA,flags)&
  &bind(c,name='rsb_get_csr')
use iso_c_binding
 type(c_ptr), value  :: matrix
 complex(c_double) :: VA(*)
 type(c_ptr), value  :: RP
 integer(c_int) :: JA(*)
 integer(c_int), value  :: flags
 end function rsb_get_csr
end interface

interface
integer(c_int) function &
  &rsb_getdiag&
  &(matrix,diagonal)&
  &bind(c,name='rsb_getdiag')
use iso_c_binding
 type(c_ptr), value  :: matrix
 complex(c_double) :: diagonal(*)
 end function rsb_getdiag
end interface

interface
integer(c_int) function &
  &rsb_get_rows_sparse&
  &(matrix,VA,fr,lr,IA,JA,rnz,alphap,trans,flags)&
  &bind(c,name='rsb_get_rows_sparse')
use iso_c_binding
 type(c_ptr), value  :: matrix
 complex(c_double) :: VA(*)
 integer(c_int), value  :: fr
 integer(c_int), value  :: lr
 integer(c_int) :: IA(*)
 integer(c_int) :: JA(*)
 integer(c_int) :: rnz
 complex(c_double) :: alphap
 integer(c_int), value  :: trans
 integer(c_int), value  :: flags
 end function rsb_get_rows_sparse
end interface

interface
integer(c_int) function &
  &rsb_get_block_sparse_pattern&
  &(matrix,fr,lr,fc,lc,IA,JA,IREN,JREN,rnz,flags)&
  &bind(c,name='rsb_get_block_sparse_pattern')
use iso_c_binding
 type(c_ptr), value  :: matrix
 integer(c_int), value  :: fr
 integer(c_int), value  :: lr
 integer(c_int), value  :: fc
 integer(c_int), value  :: lc
 integer(c_int) :: IA(*)
 integer(c_int) :: JA(*)
 type(c_ptr), value  :: IREN
 type(c_ptr), value  :: JREN
 integer(c_int) :: rnz
 integer(c_int), value  :: flags
 end function rsb_get_block_sparse_pattern
end interface

interface
integer(c_int) function &
  &rsb_get_block_sparse&
  &(matrix,VA,fr,lr,fc,lc,IA,JA,IREN,JREN,rnz,flags)&
  &bind(c,name='rsb_get_block_sparse')
use iso_c_binding
 type(c_ptr), value  :: matrix
 complex(c_double) :: VA(*)
 integer(c_int), value  :: fr
 integer(c_int), value  :: lr
 integer(c_int), value  :: fc
 integer(c_int), value  :: lc
 integer(c_int) :: IA(*)
 integer(c_int) :: JA(*)
 type(c_ptr), value  :: IREN
 type(c_ptr), value  :: JREN
 integer(c_int) :: rnz
 integer(c_int), value  :: flags
 end function rsb_get_block_sparse
end interface

interface
integer(c_int) function &
  &rsb_get_columns_sparse&
  &(matrix,VA,fc,lc,IA,JA,rnz,flags)&
  &bind(c,name='rsb_get_columns_sparse')
use iso_c_binding
 type(c_ptr), value  :: matrix
 complex(c_double) :: VA(*)
 integer(c_int), value  :: fc
 integer(c_int), value  :: lc
 integer(c_int) :: IA(*)
 integer(c_int) :: JA(*)
 integer(c_int) :: rnz
 integer(c_int), value  :: flags
 end function rsb_get_columns_sparse
end interface

interface
integer(c_int) function &
  &rsb_get_matrix_nnz&
  &(matrix)&
  &bind(c,name='rsb_get_matrix_nnz')
use iso_c_binding
 type(c_ptr), value  :: matrix
 end function rsb_get_matrix_nnz
end interface

interface
integer(c_int) function &
  &rsb_get_matrix_n_rows&
  &(matrix)&
  &bind(c,name='rsb_get_matrix_n_rows')
use iso_c_binding
 type(c_ptr), value  :: matrix
 end function rsb_get_matrix_n_rows
end interface

interface
integer(c_int) function &
  &rsb_get_matrix_n_columns&
  &(matrix)&
  &bind(c,name='rsb_get_matrix_n_columns')
use iso_c_binding
 type(c_ptr), value  :: matrix
 end function rsb_get_matrix_n_columns
end interface

interface
integer(c_int) function &
  &rsb_sizeof&
  &(matrix)&
  &bind(c,name='rsb_sizeof')
use iso_c_binding
 type(c_ptr), value  :: matrix
 end function rsb_sizeof
end interface

interface
integer(c_int) function &
  &rsb_get_block_nnz&
  &(matrix,fr,lr,fc,lc,flags,errvalp)&
  &bind(c,name='rsb_get_block_nnz')
use iso_c_binding
 type(c_ptr), value  :: matrix
 integer(c_int), value  :: fr
 integer(c_int), value  :: lr
 integer(c_int), value  :: fc
 integer(c_int), value  :: lc
 integer(c_int), value  :: flags
 integer(c_int) :: errvalp
 end function rsb_get_block_nnz
end interface

interface
integer(c_int) function &
  &rsb_get_rows_nnz&
  &(matrix,fr,lr,flags,errvalp)&
  &bind(c,name='rsb_get_rows_nnz')
use iso_c_binding
 type(c_ptr), value  :: matrix
 integer(c_int), value  :: fr
 integer(c_int), value  :: lr
 integer(c_int), value  :: flags
 integer(c_int) :: errvalp
 end function rsb_get_rows_nnz
end interface

interface
integer(c_int) function &
  &rsb_assign&
  &(new_matrix,matrix)&
  &bind(c,name='rsb_assign')
use iso_c_binding
 type(c_ptr), value  :: new_matrix
 type(c_ptr), value  :: matrix
 end function rsb_assign
end interface

interface
integer(c_int) function &
  &rsb_transpose&
  &(matrixp)&
  &bind(c,name='rsb_transpose')
use iso_c_binding
 type(c_ptr), value  :: matrixp
 end function rsb_transpose
end interface

interface
integer(c_int) function &
  &rsb_htranspose&
  &(matrixp)&
  &bind(c,name='rsb_htranspose')
use iso_c_binding
 type(c_ptr), value  :: matrixp
 end function rsb_htranspose
end interface

interface
integer(c_int) function &
  &rsb_elemental_scale&
  &(matrix,alphap)&
  &bind(c,name='rsb_elemental_scale')
use iso_c_binding
 type(c_ptr), value  :: matrix
 complex(c_double) :: alphap
 end function rsb_elemental_scale
end interface

interface
integer(c_int) function &
  &rsb_elemental_scale_inv&
  &(matrix,alphap)&
  &bind(c,name='rsb_elemental_scale_inv')
use iso_c_binding
 type(c_ptr), value  :: matrix
 complex(c_double) :: alphap
 end function rsb_elemental_scale_inv
end interface

interface
integer(c_int) function &
  &rsb_elemental_pow&
  &(matrix,alphap)&
  &bind(c,name='rsb_elemental_pow')
use iso_c_binding
 type(c_ptr), value  :: matrix
 complex(c_double) :: alphap
 end function rsb_elemental_pow
end interface

interface
integer(c_int) function &
  &rsb_update_elements&
  &(matrix,VA,IA,JA,nnz,flags)&
  &bind(c,name='rsb_update_elements')
use iso_c_binding
 type(c_ptr), value  :: matrix
 complex(c_double) :: VA(*)
 integer(c_int) :: IA(*)
 integer(c_int) :: JA(*)
 integer(c_int), value  :: nnz
 integer(c_int), value  :: flags
 end function rsb_update_elements
end interface

interface
integer(c_int) function &
  &rsb_negation&
  &(matrix)&
  &bind(c,name='rsb_negation')
use iso_c_binding
 type(c_ptr), value  :: matrix
 end function rsb_negation
end interface

interface
integer(c_int) function &
  &rsb_scal&
  &(matrix,d,trans)&
  &bind(c,name='rsb_scal')
use iso_c_binding
 type(c_ptr), value  :: matrix
 complex(c_double) :: d(*)
 integer(c_int), value  :: trans
 end function rsb_scal
end interface

interface
integer(c_int) function &
  &rsb_scale_rows&
  &(matrix,d)&
  &bind(c,name='rsb_scale_rows')
use iso_c_binding
 type(c_ptr), value  :: matrix
 complex(c_double) :: d(*)
 end function rsb_scale_rows
end interface

interface
integer(c_int) function &
  &rsb_reinit_matrix&
  &(matrix)&
  &bind(c,name='rsb_reinit_matrix')
use iso_c_binding
 type(c_ptr), value  :: matrix
 end function rsb_reinit_matrix
end interface

interface
integer(c_int) function &
  &rsb_psblas_trans_to_rsb_trans&
  &(trans)&
  &bind(c,name='rsb_psblas_trans_to_rsb_trans')
use iso_c_binding
 character(c_char), value  :: trans
 end function rsb_psblas_trans_to_rsb_trans
end interface

interface
integer(c_int) function &
  &rsb_print_matrix_t&
  &(matrix)&
  &bind(c,name='rsb_print_matrix_t')
use iso_c_binding
 type(c_ptr), value  :: matrix
 end function rsb_print_matrix_t
end interface

interface
integer(c_int) function &
  &rsb_save_matrix_file_as_matrix_market&
  &(matrix,filename)&
  &bind(c,name='rsb_save_matrix_file_as_matrix_market')
use iso_c_binding
 type(c_ptr), value  :: matrix
 type(c_ptr), value  :: filename
 end function rsb_save_matrix_file_as_matrix_market
end interface

interface
type(c_ptr) function &
  &rsb_load_matrix_file_as_matrix_market&
  &(filename,flags,typecode,errvalp)&
  &bind(c,name='rsb_load_matrix_file_as_matrix_market')
use iso_c_binding
 type(c_ptr), value  :: filename
 integer(c_int), value  :: flags
 integer(c_int), value  :: typecode
 integer(c_int) :: errvalp
 end function rsb_load_matrix_file_as_matrix_market
end interface
end module rsb_z_mod

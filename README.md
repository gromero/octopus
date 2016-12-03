File extension and respective tool that accepts it:
===================================================
.qsf -> quartus_map

You cannot use a parameter or local parameter as the size of a sized number. For
instance, it's not possible to use `K'b0`, where `K` is a parameter or local
parameter. One possible solution to that problem is to use a zero or more
multipler of a vector. For instance `{K{1'b0}}` is valid, even if `K` is equal
to zero.

snippet ns "new presenterm slide" bA

${1:Slide Title}
===

${0}
<!-- end_slide -->
endsnippet

snippet es "end slide" bA
<!-- end_slide -->

endsnippet

snippet ps "pause slide" bA
<!-- pause -->

endsnippet

snippet ss "separator slide" bA
<!-- end_slide -->

<!-- jump_to_middle -->

${1:Slide Title}
===

<!-- end_slide -->

endsnippet

snippet inc "incremental list" bA
<!-- incremental_lists: true -->

* ${1:Item 1}

<!-- incremental_lists: false -->

endsnippet

# malls can be created and accessed

    Code
      print(mall)
    Output
      <firesale mall (2)>
      $a
      test
      
      $b
      test2

---

    Code
      mall$a <- 1
    Condition
      Error in `[[<-`:
      ! You cannot replace a storefront

---

    Code
      mall[1]
    Condition
      Error in `mall[1]`:
      ! Not implemented
      i use `[[]]` or `$` to index a mall

---

    Code
      mall[1] <- 1
    Condition
      Error in `[<-`:
      ! Not implemented
      i use `[[]]` or `$` to index a mall


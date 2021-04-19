special_characters <-
  data.frame(
    matrix(c(
      # These do not work for UTF-8 in general
      #"en dash", "&#8211;",
      #"em dash", "&#8212;",
      #"left double quotation mark", "&#8220;",
      #"right double quotation mark", "&#8221;",
      #"left single quotation mark", "&#8216;",
      #"right single quotation mark", "&#8217;",
      "apostrophe", "&#39;",
      "quotation marks", "<q> your text </q>",
      "ampersand ('and' sign)", "&amp;"
    ), byrow = TRUE, ncol = 2,
    dimnames = list(NULL, c("Character", "Code")))
  )

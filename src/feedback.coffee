scoring = require('./scoring')

feedback =
  default_feedback:
    warning: ''
    suggestions: [
      #"Use a few words, avoid common phrases"
      #"No need for symbols, digits, or uppercase letters"
      "Brug nogle få ord, undgå normale sætninger"
      "Intet behov for symboler, tal, eller STORE bogstaver"
    ]

  get_feedback: (score, sequence) ->
    # starting feedback
    return @default_feedback if sequence.length == 0

    # no feedback if score is good or great.
    return if score > 2
      warning: ''
      suggestions: []

    # tie feedback to the longest match for longer sequences
    longest_match = sequence[0]
    for match in sequence[1..]
      longest_match = match if match.token.length > longest_match.token.length
    feedback = @get_match_feedback(longest_match, sequence.length == 1)
    extra_feedback = 'Tilføj et ekstra ord eller to. Unormale ord er bedre end normale.'
    if feedback?
      feedback.suggestions.unshift extra_feedback
      feedback.warning = '' unless feedback.warning?
    else
      feedback =
        warning: ''
        suggestions: [extra_feedback]
    feedback

  get_match_feedback: (match, is_sole_match) ->
    switch match.pattern
      when 'dictionary'
        @get_dictionary_match_feedback match, is_sole_match

      when 'spatial'
        layout = match.graph.toUpperCase()
        warning = if match.turns == 1
          #'Straight rows of keys are easy to guess'
          'Taster på række på tastaturet er nemme at gætte'
        else
          #'Short keyboard patterns are easy to guess'
          'Korte tastaturmønstre er nemme at gætte'
        warning: warning
        suggestions: [
          #'Use a longer keyboard pattern with more turns'
          'Brug en et længere mønster med flere drejninger'
        ]

      when 'repeat'
        warning = if match.base_token.length == 1
          #'Repeats like "aaa" are easy to guess'
          'Gentagelser som "aaa" er nemme at gætte'
        else
          #'Repeats like "abcabcabc" are only slightly harder to guess than "abc"'
          'Gentagelser som "abcabcabc" er kun en smule sværere end "abc"'
        warning: warning
        suggestions: [
          #'Avoid repeated words and characters'
          'Undgå gentagne ord og tegn'
        ]

      when 'sequence'
        #warning: "Sequences like abc or 6543 are easy to guess"
        warning: "Sekvenser som abc eller 6543 er nemme at gætte"
        suggestions: [
          #'Avoid sequences'
          'Undgå sekvenser'
        ]

      when 'regex'
        if match.regex_name == 'recent_year'
          #warning: "Recent years are easy to guess"
          warning: "Årstal fra de seneste år er nemme at gætte"
          suggestions: [
            #'Avoid recent years'
            #'Avoid years that are associated with you'
            'Undgå de seneste årstal'
            'Undgå årstal der er associeret med dig'
          ]

      when 'date'
        #warning: "Dates are often easy to guess"
        warning: "Datoer er ofte nemme at gætte"
        suggestions: [
          #'Avoid dates and years that are associated with you'
          'Undgå datoer og årstal der er associeret med dig'
        ]

  get_dictionary_match_feedback: (match, is_sole_match) ->
    warning = if match.dictionary_name == 'passwords'
      if is_sole_match and not match.l33t and not match.reversed
        if match.rank <= 10
          #'This is a top-10 common password'
          'Det her er et top-10 mest brugte password'
        else if match.rank <= 100
          #'This is a top-100 common password'
          'Det her er et top-100 mest brugte password'
        else
          #'This is a very common password'
          'Det her password er brugt af mange andre'
      else if match.guesses_log10 <= 4
        #'This is similar to a commonly used password'
        'Dette ligner andre meget anvendte passwords'
    else if match.dictionary_name == 'english_wikipedia'
      if is_sole_match
        #'A word by itself is easy to guess'
        'Et ord for sig selv er nemt at gætte'
    else if match.dictionary_name in ['surnames', 'male_names', 'female_names']
      if is_sole_match
        #'Names and surnames by themselves are easy to guess'
        'Navne og efternavne alene er nemme at gætte'
      else
        #'Common names and surnames are easy to guess'
        'Normale navne og efternavne er nemme at gætte'
    else
      ''

    suggestions = []
    word = match.token
    if word.match(scoring.START_UPPER)
      #suggestions.push "Capitalization doesn't help very much"
      suggestions.push "Stort forbogstav hjælper ikke så meget"
    else if word.match(scoring.ALL_UPPER) and word.toLowerCase() != word
      #suggestions.push "All-uppercase is almost as easy to guess as all-lowercase"
      suggestions.push "Udelukkende STORE bogstaver er næsten lige så nemt at gætte som kun små bogstaver"

    if match.reversed and match.token.length >= 4
      #suggestions.push "Reversed words aren't much harder to guess"
      suggestions.push "Ord skrevet baglæns er ikke meget sværere at gætte"
    if match.l33t
      #suggestions.push "Predictable substitutions like '@' instead of 'a' don't help very much"
      suggestions.push "Forudsigelige udskiftninger som '@' i stedet for 'a' hjælper ikke så meget"

    result =
      warning: warning
      suggestions: suggestions
    result

module.exports = feedback

time_estimates =
  estimate_attack_times: (guesses) ->
    crack_times_seconds =
      online_throttling_100_per_hour: guesses / (100 / 3600)
      online_no_throttling_10_per_second: guesses / 10
      offline_slow_hashing_1e4_per_second: guesses / 1e4
      offline_fast_hashing_1e10_per_second: guesses / 1e10

    crack_times_display = {}
    for scenario, seconds of crack_times_seconds
      crack_times_display[scenario] = @display_time seconds

    crack_times_seconds: crack_times_seconds
    crack_times_display: crack_times_display
    score: @guesses_to_score guesses


  guesses_to_score: (guesses) ->
    DELTA = 5
    if guesses < 1e3 + DELTA
      # risky password: "too guessable"
      0
    else if guesses < 1e6 + DELTA
      # modest protection from throttled online attacks: "very guessable"
      1
    else if guesses < 1e8 + DELTA
      # modest protection from unthrottled online attacks: "somewhat guessable"
      2
    else if guesses < 1e10 + DELTA
      # modest protection from offline attacks: "safely unguessable"
      # assuming a salted, slow hash function like bcrypt, scrypt, PBKDF2, argon, etc
      3
    else
      # strong protection from offline attacks under same scenario: "very unguessable"
      4

  display_time: (seconds) ->
    minute = 60
    hour = minute * 60
    day = hour * 24
    month = day * 31
    year = month * 12
    century = year * 100
    [display_num, display_str] = if seconds < 1
      #[null, 'less than a second']
      [null, 'Mindre end et sekund']
    else if seconds < minute
      base = Math.round seconds
      #[base, "#{base} second"]
      [base, "#{base} sekund"]
    else if seconds < hour
      base = Math.round seconds / minute
      #[base, "#{base} minute"]
      [base, "#{base} minut"]
    else if seconds < day
      base = Math.round seconds / hour
      #[base, "#{base} hour"]
      [base, "#{base} time"]
    else if seconds < month
      base = Math.round seconds / day
      #[base, "#{base} day"]
      [base, "#{base} dag"]
    else if seconds < year
      base = Math.round seconds / month
      #[base, "#{base} month"]
      [base, "#{base} måned"]
    else if seconds < century
      base = Math.round seconds / year
      #[base, "#{base} year"]
      [base, "#{base} år"]
    else
      #[null, 'centuries']
      [null, 'årtusinder']
    display_str = if display_str == "#{base} dag" and display_num != 1
        display_str + "e"
      else if display_str == "#{base} time" and display_num != 1
        display_str + "r"
      else if display_str == "#{base} minut" and display_num != 1
        display_str + "ter"
      else if display_num? and display_num != 1 and display_str != "#{base} år"
        display_str + "er"
      else 
        display_str
    display_str

module.exports = time_estimates


notes = {
  10 => 20,
  20 => 5,
  30 => 7,
  40 => 2
}

notes.each do |key, value|
  puts "#{key.class}, #{value}"
end
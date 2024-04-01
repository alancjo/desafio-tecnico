Dir.glob('../**/*.rb').each do |file|
  next unless file.include?("application")

  require file
end

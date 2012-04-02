guard 'minitest' do
  watch(%r|^spec/(.*)_spec\.rb|)
  watch(%r|^lib/capistrano/fanfare/(.*)([^/]+)\.rb|)  { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
end

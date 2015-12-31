clearing :on
notification :terminal_notifier if defined?(TerminalNotifier)
ignore!([
  /test\/dummy_app/,
  /byebug/
])

guard :minitest, {
  all_on_start: true,
  autorun: false,
  include: ['lib', 'test'],
  test_folders: ['test'],
  test_file_patterns: ["*_test.rb"]
} do
  watch(%r{.*}) { 'test' }
end

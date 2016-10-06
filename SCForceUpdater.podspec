Pod::Spec.new do |s|
  s.name             = "SCForceUpdater"
  s.version          = "1.0.0"
  s.summary          = "SCForceUpdater"
  s.description      = <<-DESC
                       You can easily implement force update functionality into your application with this Pod.
                       DESC
  s.homepage         = "https://github.com/team-supercharge/SCForceUpdater"
  s.license          = 'MIT'
  s.author           = { "Richard Szabo" => "richard.szabo@supercharge.io" }
  s.source           = { git: "https://github.com/team-supercharge/SCForceUpdater.git", tag: s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.ios.resource_bundle = { 'SCForceUpdater' => ['Pod/Classes/Localization/**/*.strings'] }
end


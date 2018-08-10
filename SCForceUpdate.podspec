Pod::Spec.new do |s|
  s.name             = 'SCForceUpdate'
  s.version          = '1.1.1'
  s.summary          = 'SCForceUpdate'

  s.description      = <<-DESC
                        You can easily implement force update functionality into your application with this Pod.
                        DESC

  s.homepage         = 'https://github.com/team-supercharge/SCForceUpdater'
  s.license          = 'MIT'
  s.author           = { 'Richard Szabo' => 'richard.szabo@supercharge.io' }
  s.source           = { git: 'https://github.com/team-supercharge/SCForceUpdater.git', tag: s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.source_files = 'SCForceUpdate/Classes/**/*'
  s.resource_bundles = {
      'SCForceUpdate' => ['SCForceUpdate/Classes/*.strings']
  }
end

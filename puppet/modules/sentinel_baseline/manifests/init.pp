class sentinel_baseline (
  String $project_name       = 'sentinel',
  String $environment        = 'dev',
  String $node_role          = 'generic',
  String $baseline_version   = '1.0.0',
  Array[String] $base_packages = ['curl', 'jq'],
  Array[String] $role_packages = [],
) {
  $packages_to_install = unique(concat($base_packages, $role_packages))

  package { $packages_to_install:
    ensure => installed,
  }

  package { 'chrony':
    ensure => installed,
  }

  service { 'chrony':
    ensure  => running,
    enable  => true,
    require => Package['chrony'],
  }

  file { '/etc/sentinel':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/etc/sentinel/puppet-baseline.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('sentinel_baseline/puppet-baseline.conf.epp', {
      'project_name'     => $project_name,
      'environment'      => $environment,
      'node_role'        => $node_role,
      'baseline_version' => $baseline_version,
    }),
    require => File['/etc/sentinel'],
  }

  # A small masterless enforcement timer. It runs puppet apply locally every hour.
  file { '/etc/systemd/system/sentinel-puppet-apply.service':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('sentinel_baseline/sentinel-puppet-apply.service.epp'),
    notify  => Exec['sentinel-systemd-daemon-reload'],
  }

  file { '/etc/systemd/system/sentinel-puppet-apply.timer':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('sentinel_baseline/sentinel-puppet-apply.timer.epp'),
    notify  => Exec['sentinel-systemd-daemon-reload'],
  }

  exec { 'sentinel-systemd-daemon-reload':
    command     => '/usr/bin/systemctl daemon-reload',
    refreshonly => true,
    before      => Service['sentinel-puppet-apply.timer'],
  }

  service { 'sentinel-puppet-apply.timer':
    ensure  => running,
    enable  => true,
    require => [
      File['/etc/systemd/system/sentinel-puppet-apply.service'],
      File['/etc/systemd/system/sentinel-puppet-apply.timer'],
      Exec['sentinel-systemd-daemon-reload'],
    ],
  }
}

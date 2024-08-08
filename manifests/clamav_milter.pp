# clamav_milter.pp
# Set up clamav_milter config and service.
#

class clamav::clamav_milter {

  unless (($facts['os']['family'] == 'RedHat') and (versioncmp($facts['os']['release']['full'], '7.0') >= 0)) or (
    ($facts['os']['family'] == 'Debian') and (
      (($facts['os']['name'] == 'Debian') and (versioncmp($facts['os']['release']['full'], '7.0') >= 0)) or
      (($facts['os']['name'] == 'Ubuntu') and (versioncmp($facts['os']['release']['full'], '12.0') >= 0))
    )
  ) {
    fail("OS family ${facts['os']['family']}-${facts['os']['release']['full']} is not supported. Only RedHat >= 7 is suppported.")
  }

  $config_options = $clamav::_clamav_milter_options

  package { 'clamav_milter':
    ensure => $clamav::clamav_milter_version,
    name   => $clamav::clamav_milter_package,
    before => File['clamav-milter.conf'],
  }

  file { 'clamav-milter.conf':
    ensure  => file,
    path    => $clamav::clamav_milter_config,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template("${module_name}/clamav.conf.erb"),
  }

  service { 'clamav_milter':
    ensure     => $clamav::clamav_milter_service_ensure,
    name       => $clamav::clamav_milter_service,
    enable     => $clamav::clamav_milter_service_enable,
    hasrestart => true,
    hasstatus  => true,
    subscribe  => [Package['clamav_milter'], File['clamav-milter.conf']],
  }
}

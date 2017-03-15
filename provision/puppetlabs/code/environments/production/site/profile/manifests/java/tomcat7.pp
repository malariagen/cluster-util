class profile::java::tomcat7 (
  String $java_dist    = 'jdk',
  String $java_version = 'latest',
) {

  class { 'java':
    distribution => $java_dist,
    version      => $java_version,
    before       => Class['tomcat'],
  }
}

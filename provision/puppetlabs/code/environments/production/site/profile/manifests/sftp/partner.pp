class profile::sftp::partner(
  $partners,
) {

  group { 'datarelease':
      ensure => present
  }

  file { '/etc/ssh-pool':
    ensure => directory
  }


  service { 'rsyslog':
    ensure => 'running',
    enable =>  true
  }

  $logrotate = '/var/log/sftp.log
{
  rotate 7
  daily
  missingok
  notifempty
  delaycompress
  compress
  postrotate
  reload rsyslog >/dev/null 2>&1 || true
  endscript
}'

  file { '/etc/logrotate.d/sftplog':
    content =>  $logrotate
  }

  $banner = 'MalariaGEN consortial project 1 advanced data release
-----------------------------------------------------

This sFTP site contains data on samples collected as part of MalariaGEN consortial project 1.
Data
in this folder constitutes an advanced release of study site data and is subject to MalariaGEN
terms
of use.  These terms apply to both the advanced release and the formal release of the dataset.
Full information can be found in the file home/datarelease/README.txt.

Please contact malariagen-human@well.ox.ac.uk with any queries about access to and use of the
enclosed data.
'
  file { '/mnt/d2200sb/datarelease/sftp_banner':
    content =>  $banner
  }

  $partners.each |$partner| {

    $keys = $partner[keys].reduce([]) | $memo, $value | {
      concat($memo, "${value[pubkey]}")
    }
    user { "${partner[name]}":
      gid      => 'datarelease',
    }
    file { "/etc/ssh-pool/${partner[name]}.pub":
      content => $keys.join("\n"),
      owner   => "${partner[name]}",
      group   => 'datarelease',
      mode    => '0600'
    }
    file { "/mnt/d2200sb/datarelease/${partner[name]}":
      owner   => 'root',
      group   => 'root',
      ensure => 'directory'
    }
    file { "/mnt/d2200sb/datarelease/${partner[name]}/dev":
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      ensure => 'directory'
    }
    $datadir = "/mnt/d2200sb/datarelease/${partner[name]}/home/datarelease"
    $sourcedir = "/mnt/d2200sb/datarelease/files/${partner[name]}/datarelease"

    file { "/mnt/d2200sb/datarelease/${partner[name]}/home":
      owner   => "${partner[name]}",
      group   => 'datarelease',
      mode    => '0555',
      ensure => 'directory'
    }
    file { $datadir:
      owner   => "${partner[name]}",
      group   => 'datarelease',
      mode    => '0755',
      ensure => 'directory',
      notify  => Mount[$datadir]
    }

    file { "/mnt/d2200sb/datarelease/files/${partner[name]}":
      owner   => 'root',
      group   => 'root',
      mode    => '0775',
      ensure => 'directory'
    }

    file { $sourcedir:
      owner   => "${partner[name]}",
      group   => 'datarelease',
      mode    => '0775',
      ensure => 'directory',
      notify  => Mount[$datadir]
    }

    mount { $datadir:
      fstype  => 'none',
      ensure  => 'mounted',
      options => 'bind',
      device  => $sourcedir
    }

    $logging_template = @(END)
# Create an additional socket for some of the sshd chrooted users.
$AddUnixListenSocket /mnt/d2200sb/datarelease/<%= $user %>/dev/log
local1.*  /var/log/sftp.log
# Log internal-sftp in a separate file
:programname, isequal, "sshd" -/var/log/sftp.log
:programname, isequal, "sshd" ~
END

    file { "/etc/rsyslog.d/sshd-${partner[name]}.conf":
      content => inline_epp($logging_template, { 'user' => "${partner[name]}" }),
      notify  => Service['rsyslog']
    }
  }
}

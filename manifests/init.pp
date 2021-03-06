# This puppet module sets up java jdk
# Usage:
# include jdk
class jdk($version='6') {
  if($::operatingsystem =~ /Ubuntu|Debian/){
    include apt

    apt::ppa { 'ppa:webupd8team/java': }

    $installer= $version ? {
      '7'      => 'oracle-java7-installer',
      default  => 'oracle-java6-installer'
    }

    package{$installer:
      ensure  => present,
      require => [Apt::Ppa['ppa:webupd8team/java'],
                  Exec['skipping license approval']]
    }

    package{'debconf-utils':
      ensure  => present
    }
    exec{'skipping license approval':
      command => "/bin/echo  '$installer shared/accepted-oracle-license-v1-1 boolean true' | /usr/bin/debconf-set-selections",
      user    => 'root',
      require => [Apt::Ppa['ppa:webupd8team/java'], Package['debconf-utils']]
    }

  }

    if($::operatingsystem =~ /RedHat|CentOS/) {
      $package = 'jdk-6u45-linux-x64.bin'
      $cookie = '"Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com"'
      $url = "http://download.oracle.com/otn-pub/java/jdk/6u45-b06/${package}"

      # http://getpocket.com/a/read/153528263
      exec{'download jdk':
        command  => "wget -O /tmp/${package} --no-cookies --no-check-certificate --header ${cookie} ${url}",
        user     => 'root',
        path     => '/usr/bin/'
      }

      exec{'chmod jdk package':
        command => "chmod +x /tmp/${package}",
        user    => 'root',
        path    => '/bin'
      }

      exec{'install jdk':
        command => "/tmp/${package}",
        cwd     => '/srv/opt',
        user    => 'root',
        require => [Exec['download jdk'], Exec['chmod jdk package']]
      }
      
      file { '/srv/system/java':
        ensure => link,
        target => '/srv/opt/jdk1.6.0_45',
        require => [Exec['install jdk']]
      }
    }
}

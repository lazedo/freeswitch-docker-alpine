# Maintainer: Natanael Copa <ncopa@alpinelinux.org>
# Contributor: Michael Mason <ms13sp@gmail.com>
# Contributor: Cameron Banta <cbanta@gmail.com>
pkgname=kazoo-freeswitch
pkgver=${RELEASE:-0.9.1}
pkgrel=0
pkgdesc="A communications platform written in C from the ground up"
url="http://www.freeswitch.org"
arch="all"
license="GPL"
makedepends="
	bash
	bsd-compat-headers
	coreutils
	curl-dev
	db-dev
	flac-dev
	flite-dev
	gdbm-dev
	gnutls-dev
	ilbc-dev
	lame-dev
	ldns-dev
	libedit-dev
	libexecinfo-dev
	libjpeg-turbo-dev
	libogg-dev
	libpri-dev
	libressl-dev
	libshout-dev
	libsndfile-dev
	libvorbis-dev
	linux-headers
	lua5.2-dev
	mpg123-dev
	ncurses-dev
	net-snmp-dev
	opus-dev
	pcre-dev
	perl-dev
	portaudio-dev
	postgresql-dev
	sngtc_client-dev
	speex-dev
	speexdsp-dev
	sqlite-dev
	unixodbc-dev
	util-linux-dev
	xmlrpc-c-dev
	yasm
	zlib-dev
        tiff-dev
        php7-dev
        erlang-dev
        ffmpeg-dev
	autoconf automake libtool
	"
install="$pkgname.pre-install $pkgname.pre-upgrade"
FREESWITCH_USER=freeswitch
FREESWITCH_GROUP=freeswitch
pkgusers="$FREESWITCH_USER"
pkggroups="$FREESWITCH_GROUP"
subpackages="$pkgname-dbg $pkgname-dev $pkgname-flite $pkgname-timezones::noarch
	$pkgname-sample-config:conf:noarch $pkgname-freetdm $pkgname-sangoma
	$pkgname-snmp $pkgname-pgsql $pkgname-perl"

source="$pkgname-$pkgver.tar.gz::https://${TOKEN}@github.com/lazedo/freeswitch/archive/kazoo-$pkgver.tar.gz
	0001-sofia-sip-byte-order.patch
	0001-switch-console-crash.patch
	0001-switch-core-media.patch
	0001-mod-loopback-attxfer.patch
	001-switch-buffer.patch
	0002-sofia-glue-gateway-crash.patch
	0002-FS-verto-bswap_64.patch
	001-srtp-libressl.patch
	001-ssl-libressl.patch
	001-rtmp-libressl.patch
	0001-add-asssembler-to-configure-ac.patch
	getlib.patch
	modules.conf
	kazoo-freeswitch.confd
	kazoo-freeswitch.initd
	"

builddir="$srcdir/freeswitch-kazoo-$pkgver"

prepare() {
	default_prepare
	update_config_sub
}

build() {
	cd "$builddir"

#        sed 's/php5/php7/g' -i libs/esl/php/Makefile.am
 
        ./bootstrap.sh
        
	cp -f "$srcdir/modules.conf" modules.conf

	CFLAGS="-Wno-unused-but-set-variable" ./configure \
		--build=$CBUILD \
		--host=$CHOST \
		--prefix=/usr \
		--enable-fhs \
		--localstatedir=/var \
		--sysconfdir=/etc \
		--with-scriptdir=/etc/freeswitch/scripts \
		--mandir=/usr/share/man \
		--infodir=/usr/share/info \
		--with-devrandom=/dev/urandom \
		--with-libpri \
		--disable-debug \
		--enable-core-pgsql-support \
		--enable-system-lua \
		--enable-system-xmlrpc-c

#        sed 's/php5/php7/g' -i libs/esl/php/Makefile.in 
#        sed 's/php5/php7/g' -i libs/esl/php/Makefile.am 
#        make -C libs/esl reswig

	# build freetdm with -lexecinfo
	make -C libs/freetdm LIBS="-lexecinfo"
	# first build libfreeswitch (in parallel)
	make src/include/switch_version.h src/include/switch_swigable_cpp.h
	make libfreeswitch.la
	# finally we build the rest
	make -j1 all

	# build perlesl module
#	cd "$builddir"/libs/esl
#	make -j1 perlmod
#       make -j1 phpmod

}
package(){
	cd "$builddir"
	make -j1 DESTDIR="$pkgdir" install samples-conf samples-htdocs

	install -m755 -D "$srcdir"/$pkgname.initd \
		"$pkgdir"/etc/init.d/$pkgname
	install -m644 -D "$srcdir"/$pkgname.confd \
		"$pkgdir"/etc/conf.d/$pkgname
	chown -R $FREESWITCH_USER:$FREESWITCH_GROUP "$pkgdir"/var/*/freeswitch

	# install perlesl module
#	cd "$builddir"/libs/esl
#	make -j1 DESTDIR="$pkgdir" perlmod-install
#        make -j1 DESTDIR="$pkgdir" phpmod-install
        
        cp /usr/bin/epmd "$pkgdir"/usr/bin
}


_mv_mod() {
	local moddir=usr/lib/freeswitch/mod i=
	mkdir -p "$subpkgdir"/$moddir
	for i in $@; do
		mv "$pkgdir"/$moddir/$i.so "$subpkgdir"/$moddir/
	done
}


flite() {
        pkgdesc="Freeswitch Text To Speech Module"
        install=
        _mv_mod mod_flite
##
## The mod_say_xx modules can be used with out flite (for numbers, etc using
## sound files). So they shouldn't be in the flite package -cB
##
#	_mv_mod mod_say_de mod_say_en mod_say_es mod_say_fr \
#		mod_say_it mod_say_nl mod_say_zh mod_say_hu mod_say_ru \
#		mod_say_th mod_say_he
}

freetdm() {
	pkgdesc="Freeswitch FreeTDM Module"
	install=
	_mv_mod mod_freetdm ftmod_analog ftmod_analog_em ftmod_libpri \
		ftmod_skel ftmod_zt
	mv "$pkgdir"/usr/lib/libfreetdm.so* "$subpkgdir"/usr/lib/
}

sangoma() {
	pkgdesc="Freeswitch Sangoma Media Transcode Codec Module"
	install=
	_mv_mod mod_sangoma_codec
}

timezones() {
	pkgdesc="Freeswitch timezone configuration"
	install=
	replaces="freeswitch-sample-config"
	mkdir -p "$subpkgdir"/etc/freeswitch/autoload_configs
	mv "$pkgdir"/etc/freeswitch/autoload_configs/timezones.conf.xml \
		"$subpkgdir"/etc/freeswitch/autoload_configs
}

snmp() {
	pkgdesc="Freeswitch SNMP module"
	install=
	_mv_mod mod_snmp
}

pgsql() {
	pkgdesc="Freeswitch PostgreSQL Module"
	install=
	_mv_mod mod_cdr_pg_csv
}

perl() {
	pkgdesc="Freeswitch Perl module"
	install=
	_mv_mod mod_perl
}

perlesl() {
	pkgdesc="Freeswitch Perl ESL module"
	install=
	mkdir -p "$subpkgdir"/usr/lib/perl5
	mv "$pkgdir"/usr/lib/perl5/* "$subpkgdir"/usr/lib/perl5
}

phpesl() {                                                                         
        pkgdesc="Freeswitch PHP ESL module"                                        
        install=                                                                    
        mkdir -p "$subpkgdir"/usr/lib
        mkdir -p "$subpkgdir"/etc
        mv "$pkgdir"/usr/lib/php7 "$subpkgdir"/usr/lib/
        mv "$pkgdir"/etc/php7 "$subpkgdir"/etc/
        mv "$pkgdir"/ESL.php "$subpkgdir"/ESL.php
}     

conf() {
	pkgdesc="Freeswitch sample configuration"
	depends="freeswitch-timezones"
	install=
	mkdir -p "$subpkgdir"/etc/freeswitch
	# move all configs except freeswitch.xml
	for i in "$pkgdir"/etc/freeswitch/*; do
		[ "$i" = "$pkgdir"/etc/freeswitch/freeswitch.xml ] && continue
		mv "$i" "$subpkgdir"/etc/freeswitch/
	done
	mkdir -p "$pkgdir"/etc/freeswitch/scripts
}

sha512sums="f4dc0a4d4657748b20afd0f671160a9ac3a4a9cac1d2bdb1f025ec7122d089758c80d203e41b7902fa21a4643b01237c2af1a983e2b25f6df4706510d762ac76  kazoo-freeswitch-4.3.0.tar.gz
8a7ca31cc80524b02edc83af891a32af64dd7834ac14b1389112f2ce7fe06fe602d24509a299898f25e807dd0b88544aecb990bf4bd37ee1c7023ae58dacd28a  0001-sofia-sip-byte-order.patch
89dd3a6b01290d7d71af4b32ba1cc2003e3a73fb2df1f7153a15d0a57e9d0fa316b017f7cc979980b39306da8b34e0dc494f8a392ba4b4194280a7a3d9230f8c  0001-switch-console-crash.patch
876d6746024658b13bc514e16878395f3fc8336dc846c2d74218f195593b3caab6697aceb74af72d2e41facaef7afaa336ff2597b0124b4d596507b1d5b5d33c  0001-switch-core-media.patch
2e8b449d3011455299058659773d96d8dd0fd05fbab7d57136404c6a46e62989b71c01b2aaec16a33d4a365a1c77eafb5ffc0b9c1c56043f1aced95cefeeaa07  0001-mod-loopback-attxfer.patch
59d3eba8f789d31372a78b94875386316a2fabf6989dca2da82f53f9981b8ff559674916b89ef66d41c35bffad5a055d9621de1ae8a90276c52a4811f76b1974  001-switch-buffer.patch
1217a756d9c94fff9d01426d7057c7f2aa2be63fd5965d97feca79bbde7d786b0a23be0d5a3ab957bc1b27154a72fa3ff024bf57091ef267a553c193c625cec3  0002-sofia-glue-gateway-crash.patch
5f93150e1acd632df98bc3bed5613fb1e45180ae4096dcfee5c060da213c8355339260eaf5758cd77c785f6d84cf0661650a872ec574b586ab19803d4f6955f8  0002-FS-verto-bswap_64.patch
d596c529cfa7626374143f350f7357340c5086e014f9b4f895023a6feca472157fe8e5c0ef2f501933d2a7c1b656f20b3a68e14d1f815430128f925736914f82  001-srtp-libressl.patch
1f1db8be11bedf50a5cb1ac3e36dc13fc10b11f43aa444b1c9ee72d1e7591db0228dbd65d5f33a70f71c52c0332e3e3867888dcde0f3098439d3fab29bc2997a  001-ssl-libressl.patch
f043341ce03a16f0c39631b66666b210283c08f462cb03db327d10de38c285985ef5f8505ccad941946b030100ad80c8595d0d216975a5029a31dc68f9dee9d3  001-rtmp-libressl.patch
50362d069174aeeaf7d8cc993d32c319f110e6776c1c94b4fd6f3f255bd82e9155f9cbca93cacd7c8fee4107d7a9c40327466b2ada49272e3064cd0345b53ab3  0001-add-asssembler-to-configure-ac.patch
4ceb48f64d2bc26a02cc0846276506241bfd30c156422b0a1d608fd172c099feb5c121a763652e9a45046dcdd0ba0eb71eab240e0c6ce2ad63ff781719e135a4  getlib.patch
81afddd92c100d266d5ad1ff8b919a3a91fcca714b9d10a466b98bdcffd359d8c21c5a1c81df70811f44018216743af554b22f5e327a5743c046c7b79fb65767  modules.conf
a585f6411185a26206137a1ad97a06fd6c73e80c5439e9be45eabfa70e7a83120169ba882971fcd328436c8e0242cbd664170b80754ea2846021689baf1f1595  kazoo-freeswitch.confd
643d0a2e43f5d3bf3b99fcb6f6422302cb4b74a95eccf844eafb100b15aa9856b4ff41f112d6637255c2e9e2bec9fedc9a9215dfff214dfb83b52eae16b71dca  kazoo-freeswitch.initd"

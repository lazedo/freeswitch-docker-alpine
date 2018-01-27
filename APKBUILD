# Maintainer: Natanael Copa <ncopa@alpinelinux.org>
# Contributor: Michael Mason <ms13sp@gmail.com>
# Contributor: Cameron Banta <cbanta@gmail.com>
pkgname=freeswitch
pkgver=1.9.0
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

source="$pkgname-$pkgver.tar.xz
	0001-FS-10774-switch_pgsql-Fix-build-for-PostgreSQL-libpq.patch
	0001-sofia-sip-byte-order.patch
	0001-mod_spandsp-max-tones.patch
	0001-switch-console-crash.patch
	0002-sofia-glue-gateway-crash.patch
	0002-FS-verto-bswap_64.patch
	001-rtmp-libressl.patch
	getlib.patch
	modules.conf
	freeswitch.confd
	freeswitch.initd
	"

builddir="$srcdir/$pkgname-$pkgver"

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
	pkgdesc="Freeswitch sample configureation"
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

sha512sums="ef663c7eb91ea4d20b6c24157dc121358e500620e965165c03b78a7e7d005213425921d798416a8b40cf91615431f9e18d91b8af3aa6b29bad7b430fd3255933  freeswitch-1.9.0.tar.xz
db61d9a253105f7a1ef5f5c218b367a833f62a2e85e364e3971acc79f68037b0270c5b2f3e0909643278b6b93104ac8e59b323470aeef5f519c33b0289c0fcf3  0001-FS-10774-switch_pgsql-Fix-build-for-PostgreSQL-libpq.patch
8a7ca31cc80524b02edc83af891a32af64dd7834ac14b1389112f2ce7fe06fe602d24509a299898f25e807dd0b88544aecb990bf4bd37ee1c7023ae58dacd28a  0001-sofia-sip-byte-order.patch
5f93150e1acd632df98bc3bed5613fb1e45180ae4096dcfee5c060da213c8355339260eaf5758cd77c785f6d84cf0661650a872ec574b586ab19803d4f6955f8  0002-FS-verto-bswap_64.patch
f043341ce03a16f0c39631b66666b210283c08f462cb03db327d10de38c285985ef5f8505ccad941946b030100ad80c8595d0d216975a5029a31dc68f9dee9d3  001-rtmp-libressl.patch
4ceb48f64d2bc26a02cc0846276506241bfd30c156422b0a1d608fd172c099feb5c121a763652e9a45046dcdd0ba0eb71eab240e0c6ce2ad63ff781719e135a4  getlib.patch
81afddd92c100d266d5ad1ff8b919a3a91fcca714b9d10a466b98bdcffd359d8c21c5a1c81df70811f44018216743af554b22f5e327a5743c046c7b79fb65767  modules.conf
a585f6411185a26206137a1ad97a06fd6c73e80c5439e9be45eabfa70e7a83120169ba882971fcd328436c8e0242cbd664170b80754ea2846021689baf1f1595  freeswitch.confd
643d0a2e43f5d3bf3b99fcb6f6422302cb4b74a95eccf844eafb100b15aa9856b4ff41f112d6637255c2e9e2bec9fedc9a9215dfff214dfb83b52eae16b71dca  freeswitch.initd"

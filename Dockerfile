FROM resin/rpi-raspbian:jessie

MAINTAINER Yoran Maulny <yoran.maulny@gmail.com>

# Default configuration
COPY mopidy.conf /var/lib/mopidy/.config/mopidy/mopidy.conf

# Start helper script
COPY entrypoint.sh /entrypoint.sh

# Official Mopidy install for Debian/Ubuntu along with some extensions
# (see https://docs.mopidy.com/en/latest/installation/debian/ )

# Add tool need by Mopidy
RUN apt-get update
RUN apt-get install -y \
        curl \
        gcc \
        gstreamer0.10-alsa \
        python-crypto

# Add Mopidy repository and install Mopidy and extension
 RUN curl -L https://apt.mopidy.com/mopidy.gpg -o /tmp/mopidy.gpg \
 && curl -L https://apt.mopidy.com/mopidy.list -o /etc/apt/sources.list.d/mopidy.list \
 && apt-key add /tmp/mopidy.gpg \
 && apt-get install -y \
        mopidy \
        mopidy-soundcloud \
        mopidy-spotify

# Install Pip and python Mopidy extension
RUN curl -L https://bootstrap.pypa.io/get-pip.py | python -
RUN pip install -U six
RUN pip install Mopidy-Moped
#RUN pip install Mopidy-GMusic
RUN pip install Mopidy-YouTube
RUN pip install pyasn1==0.1.8

RUN apt-get install -y \
    python-dev \
    build-essential
RUN pip install Mopidy-GMusic

# Install Deezer plugin
#RUN apt-get update && apt-get install -y git
RUN apt-get install -y git
RUN git clone https://github.com/rusty-dev/mopidy-deezer
#RUN cd mopidy-deezer
RUN pip install ./mopidy-deezer --upgrade

# Clean after install
RUN apt-get purge --auto-remove -y \
        curl \
        gcc \
        git \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache

# Add file to  group mopidy:audio
RUN chown mopidy:audio -R /var/lib/mopidy/.config \
 && chown mopidy:audio /entrypoint.sh

# Run as mopidy user
USER mopidy

VOLUME /var/lib/mopidy/local
VOLUME /var/lib/mopidy/media

EXPOSE 6600
EXPOSE 6680

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/mopidy"]

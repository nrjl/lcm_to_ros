# LCM Volturnus

This package is to subscribe to and republish LCM messages from the Greenseas INS on Volturnus into ROS messages. This package is **NOT** for general distribution, as it may fall under confidentiality agreements with Greenseas Inc.

## Installation:

Install LCM:
'''
git clone https://github.com/lcm-proj/lcm lcm
cd lcm
./bootstrap.sh
./configure
make
sudo make install
'''

Create lcm message types (stat_XYZ.lcm) then create the CPP headers:
'''
lcm-gen -x stat_*.lcm
'''

They will be created in the exlcm subfolder.


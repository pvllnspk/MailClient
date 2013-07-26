#!/usr/bin/sh
# for this to work you need to have the following installed:
# - git: http://help.github.com/mac-git-installation/

# pull MailCore
cd ..
git clone https://github.com/MailCore/MailCore.git
cd MailCore/
git submodule update --init
cd -
cd MailClient/

# pull DTCoreText
cd Externals/
git clone https://github.com/Cocoanetics/DTCoreText.git
cd DTCoreText/
git submodule update --init --recursive
cd ..

# this should be it - you can now open the MailClient Xcode project
echo "Done - if you didn't see errors, you can now open the MailClient Xcode project"

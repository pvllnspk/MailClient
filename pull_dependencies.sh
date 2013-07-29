#!/usr/bin/sh
# for this to work you need to have the following installed:
# - git: http://help.github.com/mac-git-installation/

# pull DTCoreText
cd Externals/
git clone https://github.com/Cocoanetics/DTCoreText.git
cd DTCoreText/
# use an already tested version
git checkout -b dev ef7725802735d10b89a6020411958c6c98106cf1
git submodule update --init --recursive
cd ..
cd ..

# pull MailCore
cd ..
git clone https://github.com/MailCore/MailCore.git
cd MailCore/
# use an already tested version
git checkout -b dev 1b20901351814d773295e3928a837dcf513d147f
git submodule update --init
cd -

# this should be it - you can now open the MailClient Xcode project
echo "Done - if you didn't see errors, you can now open the MailClient Xcode project"

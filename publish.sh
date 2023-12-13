
version=$1

cd example
flutter clean && flutter pub get
cd ..
flutter clean && flutter pub get
dart format .
git add .
git commit -m "${version} release"
git push
git checkout master
git merge dev
git push
git tag ${version} && git push origin ${version}
flutter pub publish

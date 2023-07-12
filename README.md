# TodoApp
## 開発環境
- Mac OS Ventura 13.0 
- Xcode 14.2
- Swift 5.7.2 
- CocoaPods 1.12.0

## 起動方法
1. 以下のGitHubリポジトリからプロジェクトをクローンします。 
    https://github.com/syogo-user/TodoApp.git
2. 1のフォルダ階層でターミナルを起動します。
3. ターミナル上で「pod install」コマンドを実行します。
4. 「TodoApp.xcworkspace」からXcodeを起動します。
5. 別途添付の「amplifyconfiguration.json」と「awsconfiguration.json」を Finder上で「TodoApp」配下の階層にコピーします。
6. Xcodeにてアプリを実行します。
7. ログイン画面が表示されます。ソーシャルログインを採用しているため、お手数ですが、ご自身でお持ちのGoogleまたはAppleアカウントにてログインをお願いします。
    ※なお、一つのアカウントで複数人同時ログインは行わないようにお願いします。

## アーキテクチャ
- 3層レイヤードアーキテクチャを採用(Presentation層、Domain層、Infra層)
- [クラス図](document/クラス図.pdf)
- [サーバー構成](document/サーバー構成.pdf)

## コーディングについて
- 以下のガイドラインをもとにコードを実装しています。
https://google.github.io/swift/

- 変数やメソッドの定義順序
  - 意味のまとまりごとに定義
  - 同じまとまりの場合、アクセス修飾子による公開度の大きい順に定義
    (public -> private)
# Rust 标准库中文版


这是翻译 [Rust 库](https://github.com/rust-lang/rust/tree/master/library) 的地方， 相关源代码来自于 <https://github.com/rust-lang/rust>。

如果您不会说英语，那么拥有使用中文的文档至关重要，即使您会说英语，使用母语也仍然能让您感到愉快。Rust 标准库是高质量的，不管是新手还是老手，都可以从中受益。

该仓库包含 `rust-src` 组件的所有源代码文件，并对其所有的源代码进行翻译，主要包括对 Rust 核心库的翻译，Rust 标准库的翻译，以及其他一些资源。该仓库使用 [`Cmtor`](#) (我写的效率工具) 程序并借助 `JSON` 文件来完成翻译的所有工作，当 Rust 更新时，将尽可能为其生成中文翻译。




## 下载翻译好的 Rust 文档

每次在构建新的中文文档时，会修复之前构建结果中存在的问题，为了尽可能的保证翻译的准确性，本仓库只提供最新版本的构建。最新的构建结果会放在 [`dist`](./dist) 目录下，您可以手动跳转到该文件夹，下载最新的构建结果。




## 使用 Rust 中文文档

> - 在使用中文文档时，请注意版本号，中文文档版本和 Rust 版本号必须要保持一致。
> - 必须使用 `stable` 版本，不要使用 `beta` 和 `nightly` 版本。
> - 在翻译后的源代码中，一些文档的底部会存在一定量的内容为空的注释行，其实这是有意为之，请不要擅自修改和删除。如果您删除了它，就会导致 `source-map` 失效，当 `source-map` 失效后，在调试源代码时就会出现执行位置和源代码位置不一致的严重问题。



如果您是刚开始使用 Rust，那么请确保 Rust 已经安装好，并且可以正常工作。在 Rust 安装成功后，您还应该通过 `rustup component add rust-src` 命令来安装 `rust-src` 组件。当安装 `rust-src` 组件之后，请按照以下步骤进行操作：

1. 在终端执行: `rustup default stable` 来切换到 `stable` 版本，并确保 `stable` 的版本与中文版文档所对应的版本一致
2. 在终端执行 `rustup show`，然后在输出中找到 `rustup home` 所对应的路径，然后将其在资源管理器中打开
3. 打开 `toolchains` 的文件夹，在该文件夹下，找到您当前所使用的 Rust 工具链并将其打开，例如，在 `Windows` 平台上对应的是 `stable-x86_64-pc-windows-msvc` 文件夹
4. 然后打开 `lib/rustlib/src/rust` 目录，这个目录下的文件夹就是 Rust 标准库源代码所在的位置
5. 将 `lib/rustlib/src/rust/library` 文件夹下的所有内容保存一份副本
6. 下载本仓库对应的中文文档源文件，将其重命名为 `library` 并放置到 `lib/rustlib/src/rust` 文件夹下
7. 请确保您已经在 IDE 中安装 Rust 相关插件，例如，`vscode` 需要安装：[rust-analyzer](https://marketplace.visualstudio.com/items?itemName=matklad.rust-analyzer)
8. 重新启动 `IDE` 工具，中文文档的智能提示开始工作
9. 愉快的编码！



## 离线 HTML 文档

该中文翻译为源码级翻译，现在您可以轻松的构建离线的 HTML 文档供自己阅读。在构建离线 HTML 文档之前，您需要了解一些 Git 操作知识以及 Rust 构建流程。在这里，仅提供 HTML 离线文档的构建命令。

有关构建离线文档的更多信息，请参见：[构建离线 HTML 文档](./BuildHtml.md)



## Gitee 国内镜像

为了方便国内朋友的下载和访问，Github 上的 [rust-library-i18n](https://github.com/wtklbm/rust-library-i18n) 仓库已同步到了 Gitee，项目地址为: <https://gitee.com/wtklbm/rust-library-chinese>，其中 [rust-library-chinese](https://gitee.com/wtklbm/rust-library-chinese) 仅为镜像仓库，如果您想找到我，请在 [Github](https://github.com/wtklbm) 上进行留言。




## NOTE

该翻译底层基于机器翻译，但优于纯机器翻译，它只会翻译该翻译的地方，并能够保证所翻译的文档和英文文档是完全同步的，不会产生文档脱节的情况。

在翻译的过程中，因为多方面原因，难免会出现一些计算机专有名词意外被翻译，或者某些单词使用不当的情况，这个翻译我自己就在使用，翻译就是为了方便自己学习和成长，所以发现了问题就会修复，请别见怪。

该仓库以前打算是支持多种语言，实时更新的(完全绰绰有余)，经过几个月下来，这些功能已经变得不那么重要，第一是因为没人愿意去校对那些语句字符串，第二就是把时间放到更能提升自己，更有意义的事情上去。所以该项目的更新策略调整为：尽量更新。除此之外，不做任何保证。




## Others

### `crm`

`crm` 是一个镜像源管理工具，内置了 5 种 Rust 国内镜像源，并提供了测速功能，更换镜像源特别方便。

- [从 Github 访问](https://github.com/wtklbm/crm)
- [从 Gitee 访问](https://gitee.com/wtklbm/crm)




## License

MIT OR Apache-2.0
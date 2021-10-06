const { join } = require('path');
const { readdir, writeFile } = require('fs/promises');

const toJSON = value => JSON.stringify(value, null, '    ') + '\n';

const rectifies = [
    // ...
];

async function main() {
    const rootDir = join(__dirname, './sentences/zh-CN');
    const relativePaths = await readdir(rootDir);

    for (let i = 0, len = relativePaths.length; i < len; i++) {
        const filePath = join(rootDir, relativePaths[i]);
        const sentences = require(filePath);

        for (let i = 0, len = sentences.length, sentence; i < len; i++) {
            sentence = sentences[i];
            let { source, suggest } = sentence;

            rectifies.forEach(({ match, error, to }) => {
                if (match.test(source)) {
                    while (error.test(suggest)) {
                        suggest = suggest.replace(error, to);
                    }

                    sentence.suggest = suggest;
                }
            });
        }

        await writeFile(filePath, toJSON(sentences));
    }
}

main().then(console.log, console.error);

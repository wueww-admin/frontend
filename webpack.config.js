const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = {
    entry: './src/index.js',
    output: {
        filename: './app.js'
    },
    plugins: [
        new HtmlWebpackPlugin({
            title: 'WueWW Admin',
            template: './public/index.html',
        }),
    ]
}
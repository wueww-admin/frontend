const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = {
    entry: './src/index.js',
    output: {
        filename: './app.js',
    },
    resolve: {
        extensions: ['.js', '.elm'],
    },
    module: {
        rules: [
            {
                test: /\.scss$/,
                use: ['style-loader', 'css-loader', 'sass-loader'],
            },
            {
                test: /\.elm$/,
                exclude: [/elm-stuff/, /node_modules/],
                use: {
                    loader: 'elm-webpack-loader',
                    options: {},
                },
            },
        ],
    },
    plugins: [
        new HtmlWebpackPlugin({
            title: 'WueWW Admin',
            template: './public/index.html',
        }),
    ],
};

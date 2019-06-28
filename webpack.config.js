const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = {
    entry: './src/index',
    output: {
        filename: './app.js',
    },
    resolve: {
        extensions: ['.elm', '.ts', '.js'],
    },
    module: {
        rules: [
            { test: /\.tsx?/, loader: 'ts-loader' },
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
    devServer: {
        proxy: {
            '/api': {
                target: 'http://wueww-admin.metafnord.de/',
                headers: {
                    Host: 'wueww-admin.metafnord.de',
                },
            },
        },
    },
};

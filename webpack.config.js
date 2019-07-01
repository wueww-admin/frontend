const CopyWebpackPlugin = require('copy-webpack-plugin');
const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = (env, argv) => ({
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
                    options: {
                        optimize: argv.mode === 'production',
                    },
                },
            },
            {
                test: /\.jpe?g$|\.gif$|\.png$|\.ttf$|\.eot$|\.svg$/,
                use: 'file-loader?name=[name].[ext]?[hash]',
            },
            {
                test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
                loader: 'url-loader?limit=10000&mimetype=application/fontwoff',
            },
        ],
    },
    plugins: [
        new HtmlWebpackPlugin({
            title: 'WueWW Admin',
            template: './public/index.html',
        }),
        new CopyWebpackPlugin([{ from: 'public/assets', to: 'assets' }]),
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
});

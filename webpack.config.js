const path = require('path');

const webpack = require("webpack");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");

module.exports = (env, argv) => {
  let isProduction;
  switch (argv.mode) {
    case "production":
      isProduction = true;
      break;
    case "development":
      isProduction = false;
      break;
    default:
      throw new Error("Unrecognised --mode: '" + argv.mode + "'");
  }

  return {
    entry: {
      main: [
        './src/index.js'
      ]
    },

    output: {
      path: path.resolve(__dirname + '/dist'),
      filename: 'assets/[name].js',
    },

    module: {
      rules: [{
          test: /\.html$/,
          exclude: /node_modules/,
          loader: 'file-loader',
          options: {
            name: '[name].[ext]'
          }
        },
        {
          test: /\.elm$/,
          exclude: [/elm-stuff/, /node_modules/],
          use: [
            {
              loader: 'elm-css-modules-loader',
            },
            {
              loader: 'elm-webpack-loader',
              options: {
                debug: !isProduction,
                warn: true
              }
            }
          ],
        },
        {
          test: /\.css$/,
          loaders: [
            MiniCssExtractPlugin.loader,
            {
              loader: 'css-loader',
              options: { modules: true }
            }
          ],
        }
      ]
    },

    plugins: [
      new webpack.DefinePlugin({
        'process.env.NODE_ENV': JSON.stringify(
          process.env.NODE_ENV || 'development'
        ),
        'process.env.API_BASE_URL': JSON.stringify(
          process.env.API_BASE_URL
        )
      }),

      // Extract the CSS to its own separate file.
      new MiniCssExtractPlugin({
        filename: "assets/[name].css"
      }),
    ],

    devServer: {
      inline: true,
      stats: 'errors-only'
    }
  };
};

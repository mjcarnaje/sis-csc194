/** @type {import('tailwindcss').Config} */
module.exports = {
  mode: "jit",
  content: ["./templates/**/*.{html,js}", "./static/js/*.js"],
  theme: {
    extend: {},
  },
  plugins: [require("daisyui")],
};

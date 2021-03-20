import Vue from 'vue';
import Vuetify from 'vuetify/lib/framework';

Vue.use(Vuetify);

export default new Vuetify({
    theme: {
        themes: {
          light: {
            primary: "#3A356D",
            secondary: "#F8EADC",
            accent: "#3BA2CB"
          },
        },
      },
});

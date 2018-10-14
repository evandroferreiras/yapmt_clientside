<template>
  <v-app>
    <v-navigation-drawer
      persistent
      :clipped='clipped'
      v-model='drawer'
      enable-resize-watcher
      app
    >
      <v-list>
        <v-list-tile
          value='true'
          v-for='(item, i) in items'
          :key='i'
          v-bind:class='{ selected: (i === idxSelected) }'
          v-on:click='selectProject(i)'
        >
          <v-list-tile-action>
            <v-icon v-html='icon'></v-icon>
          </v-list-tile-action>
          <v-list-tile-content >
            <v-list-tile-title v-bind:class='{ selected: (i === idxSelected) }' v-text='item.title'></v-list-tile-title>
          </v-list-tile-content>
        </v-list-tile>

      </v-list>
      <v-list>
        <v-list-tile value='true' v-on:click='newProject()'>
          <v-list-tile-action>
            <v-icon>control_point</v-icon>
          </v-list-tile-action>
          <v-list-tile-content >
            <v-list-tile-title v-text="'New project'"></v-list-tile-title>
          </v-list-tile-content>
        </v-list-tile>

      </v-list>
    </v-navigation-drawer>
    <v-toolbar
      app
      :clipped-left='clipped'
    >
      <v-toolbar-side-icon @click.stop='drawer = !drawer'></v-toolbar-side-icon>
      <v-toolbar-title v-text='app_title'></v-toolbar-title>
      <v-spacer></v-spacer>
    </v-toolbar>
    <v-content>
      <router-view :idx=idxSelected :items=items  />
    </v-content>
    <v-footer app>
      <span>&copy; 2018</span>
    </v-footer>
  </v-app>
</template>

<script>
import axios from 'axios';

export default {
  data() {
    return {
      clipped: false,
      drawer: true,
      icon: 'blur_on',
      items: [],

      app_title: 'YAMT',
      idxSelected: -1,
      itemSelected: '',
    };
  },
  mounted: function mounted() {
    this.getProjects();
  },
  methods: {
    getProjects: function getProjects() {
      axios.get(`${process.env.API_URL}/projects`)
      .then((response) => {
        this.items = response.data;
      });
    },
    newProject: function newProject() {
      const data = { title: 'New project' };
      axios.post(`${process.env.API_URL}/projects`, data)
            .then(
              (response) => {
                const id = this.items.push(response.data) - 1;
                this.selectProject(id);
              },
            );
    },
    selectProject: function selectProject(i) {
      this.idxSelected = i;
      this.itemSelected = this.items[i];
    },
  },
  name: 'App',
};
</script>

<style scoped>
  .selected {
    color: darkblue;
    font-weight: bolder;
    background-color: gainsboro


  }
</style>

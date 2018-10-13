<template>
  <v-container fluid>
    <v-slide-y-transition mode='out-in'>
      <v-layout row align-center>
        <v-flex v-if="project">
          <v-card>
            <v-card-actions>
              <v-spacer></v-spacer>

              <v-btn flat color='red' @click='deleteSelected' >Delete Tasks</v-btn>
              <v-btn color='red' dark @click="dialog = true" >Delete Project</v-btn>
            </v-card-actions>
            <v-divider></v-divider>
            <v-card-title primary-title>
              <div>
                <h3><v-text-field :value='project.title' v-model='project.title'> </v-text-field> </h3>

              </div>
            </v-card-title>
            <v-card-text >
              <div>
                <v-checkbox v-model='selectedTasks' v-bind:key=i v-for='(task, i) in tasks' :label="task.description + ', ' + task.username + ', ' + task.dueTime" :value='task'></v-checkbox>
              </div>

              <div >
                <v-form v-model="valid" ref="form">
                  <v-card-actions>
                    <v-text-field :rules="taskDescriptionRules" label='new task' v-on:keyup='validateTask' v-model='newTask.description' required></v-text-field>
                    <v-text-field :rules="taskUsernameRules" label='@username' v-on:keyup='validateTask' v-model='newTask.username' required></v-text-field>
                    <v-text-field :rules="taskDueTimeRules" label='due time' v-on:keyup='validateTask' v-model='newTask.dueTime' required></v-text-field>
                    <v-btn flat color='green' @click='addTask'>Add</v-btn>
                  </v-card-actions>
                </v-form>
              </div>
            </v-card-text>
          </v-card>
        </v-flex>

      </v-layout>
    </v-slide-y-transition>

    <v-layout row justify-center>
      <v-dialog
        v-model="dialog"
        max-width="290"
      >
        <v-card>
          <v-card-title class="headline">Delete project</v-card-title>

          <v-card-text>
            Are you sure you want to delete the project "{{items[idx].title}}"?
          </v-card-text>

          <v-card-actions>
            <v-spacer></v-spacer>

            <v-btn
              color="red darken-1"
              flat="flat"
              @click="dialog = false"
            >
              No
            </v-btn>

            <v-btn
              color="green darken-1"
              flat="flat"
              @click='deleteProject'
            >
              Yes! I'm sure
            </v-btn>
          </v-card-actions>
        </v-card>
      </v-dialog>
    </v-layout>
  </v-container>
</template>

<script>
export default {
  props: {
    idx: {

    },
    items: {

    },
  },
  watch: {
    idx: function watchMyProp(newVal, oldVal) { // watch it
      // eslint-disable-next-line
      console.log('Prop changed: ', newVal.title, ' | was: ', oldVal.title);
      this.project = this.items[newVal];
    },
  },
  data() {
    return {
      project: null,
      valid: false,
      dialog: false,
      taskDescriptionRules: [
        v => !!v || 'Description is required',
      ],
      taskUsernameRules: [
        v => !!v || 'Username is required',
        v => (v && !!(v.startsWith('@') && v.length > 1)) || 'Username has to starts with "@"',
      ],
      taskDueTimeRules: [
        v => !!v || 'Due time is required',
        v => (v && !!v.match(/^((\d\d)\/(\d\d))$/gm)) || 'Due time has to have the format dd/MM',
      ],
      tasks: [
        { id: 1, description: 'task1', username: '@user1', dueTime: '10/01' },
        { id: 2, description: 'task2', username: '@user2', dueTime: '10/14' },
        { id: 3, description: 'task3', username: '@user3', dueTime: '10/30' },
      ],
      selectedTasks: [],
      newTask: {
        description: '',
        username: '',
        dueTime: '',
      },
    };
  },
  methods: {
    validateTask: function validateTask(e) {
      if (e.keyCode === 13) {
        this.addTask();
      }
    },
    addTask: function addTask() {
      if (this.$refs.form.validate()) {
        if (this.newTask) {
          this.tasks.push(Object.assign({}, this.newTask));
          this.$refs.form.reset();
        }
      }
    },
    deleteSelected: function deleteSelected() {
      this.selectedTasks.forEach((task) => {
        this.tasks.splice(this.tasks.indexOf(task), 1);
      });

      this.selectedTasks = [];
    },
    deleteProject: function deleteProject() {
      this.items.splice(this.idx, 1);
      this.project = null;
      this.dialog = false;
    },
  },
};
</script>


<!-- Add 'scoped' attribute to limit CSS to this component only -->
<style scoped>
h1,
h2 {
  font-weight: normal;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #42b983;
}
</style>

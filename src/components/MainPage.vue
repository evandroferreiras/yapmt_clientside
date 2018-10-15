<template>
  <v-container fluid>
    <v-slide-y-transition mode='out-in'>
      <v-layout row align-center>
        <v-flex v-if="project">
          <v-card>
            <v-card-actions>
              <v-spacer></v-spacer>
                {{projectSummary.completed}} | {{projectSummary.late}} | {{projectSummary.total}}
              <v-spacer></v-spacer>
              <v-btn color='red' dark @click="dialog = true" >Delete Project</v-btn>
            </v-card-actions>
            <v-divider></v-divider>
            <v-card-title primary-title>
              <div>
                <v-form v-model="validProject" ref="formProject">
                <h3><v-text-field :rules="taskDescriptionRules" :value='projectTitle' v-model='projectTitle' v-on:change="updateProjectTitle"> </v-text-field> </h3>
                </v-form>
              </div>
            </v-card-title>
            <v-card-text >
              <div>
                <v-list>
                  <v-list-tile
                      value='true'
                      v-for='(task, i) in tasks'
                      :key='i'
                    >
                    <v-list-tile-content>
                      <v-checkbox v-bind:class='{ strikethrough: (task.checked)}' v-on:change="updateTask(task)" v-model='task.checked' :label="task.description + ', ' + task.username + ', ' + task.dueTimeStatus" ></v-checkbox>
                    </v-list-tile-content>
                    <v-list-tile-action>
                      <v-icon  color="red" v-if="task.statusTask === 'late'">alarm</v-icon>
                    </v-list-tile-action>
                    <v-list-tile-action>
                      <v-icon @click="deleteTask(task)">delete</v-icon>
                    </v-list-tile-action>

                  </v-list-tile>
                </v-list>
                <!-- <v-checkbox  v-model='task.checked' v-bind:key=i v-for='(task, i) in tasks' :label="task.description + ', ' + task.username + ', ' + task.dueTime" ></v-checkbox> -->
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

    <v-layout row justify-center v-if="project">
      <v-dialog
        v-model="dialog"
        max-width="290"
      >
        <v-card>
          <v-card-title class="headline">Delete project</v-card-title>

          <v-card-text>
            Are you sure you want to delete the project "{{project.title}}"?
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
import axios from 'axios';

export default {
  props: {
    idx: {

    },
    items: {

    },
  },
  watch: {
    idx: function watchMyProp(newVal) {
      this.project = this.items[newVal];
      this.projectTitle = this.items[newVal].title;
      this.getTasks();
    },
    tasks: function watchTasks() {
      this.refreshSummary();
    },
  },
  data() {
    return {
      projectSummary: {
        completed: 0,
        total: 0,
        late: 0,
      },
      project: null,
      projectTitle: '',
      valid: false,
      validProject: false,
      dialog: false,
      projectTitleRules: [
        v => !!v || 'Title is required',
      ],
      taskDescriptionRules: [
        v => !!v || 'Description is required',
      ],
      taskUsernameRules: [
        v => !!v || 'Username is required',
        v => (v && !!(v.startsWith('@') && v.length > 1)) || 'Username has to starts with "@"',
      ],
      taskDueTimeRules: [
        v => !!v || 'Due time is required',
        v => (v && !!v.match(/^((\d\d)\/(\d\d))$/gm)) || 'Due time has to have the format MM/dd',
      ],
      tasks: [],
      newTask: {
        description: '',
        username: '',
        dueTime: '',
        checked: false,
      },
    };
  },
  methods: {
    refreshSummary: function refreshSummary() {
      axios.get(`${process.env.API_URL}/projects/${this.project.id}/summary`)
      .then(
        (response) => {
          this.projectSummary = response.data;
        },
      );
    },
    getTasks: function getTasks() {
      axios.get(`${process.env.API_URL}/tasks/projectId=${this.project.id}`)
      .then((response) => {
        this.tasks = response.data;
      });
    },
    updateTask: function updateTask(task) {
      axios.put(`${process.env.API_URL}/tasks/${task.id}`, task)
        .then(() => {
          this.refreshSummary();
          this.getTasks();
        });
    },
    updateProjectTitle: function updateProjectTitle() {
      if (this.$refs.formProject.validate()) {
        const projectId = this.project.id;
        axios.put(`${process.env.API_URL}/projects/${projectId}`, { title: this.projectTitle })
              .then(
                (response) => {
                  if (response.status === 200) {
                    this.project = response.data;
                    this.items[this.idx].title = this.project.title;
                    this.projectTitle = this.project.title;
                  }
                },
              );
      } else {
        this.projectTitle = this.project.title;
      }
    },
    validateTask: function validateTask(e) {
      if (e.keyCode === 13) {
        this.addTask();
      }
    },
    addTask: function addTask() {
      if (this.$refs.form.validate()) {
        if (this.newTask) {
          this.newTask.projectId = this.project.id;
          axios.post(`${process.env.API_URL}/tasks`, this.newTask)
            .then(
              (response) => {
                this.tasks.push(response.data);
                this.$refs.form.reset();
              },
            );
        }
      }
    },
    deleteTask: function deleteTask(task) {
      axios.delete(`${process.env.API_URL}/tasks/${task.id}`)
        .then(() => {
          this.tasks.splice(this.tasks.indexOf(task), 1);
          this.refreshSummary();
        });
    },
    deleteProject: function deleteProject() {
      const projectId = this.project.id;
      axios.delete(`${process.env.API_URL}/projects/${projectId}`)
            .then(
              () => {
                this.items.splice(this.idx, 1);
                this.project = null;
                this.dialog = false;
              },
            );
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
.strikethrough {
  text-decoration: line-through;
}

.late {
  color: red !important
}

a {
  color: #42b983;
}
</style>

module.exports = function(grunt) {
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    // Using the BrowserSync Server for your static .html files.
    browserSync: {
      default_options: {
        bsFiles: {
          src: [
            "css/*.css",
            "*.html"
          ]
        },
        options: {
          watchTask: true,
          server: {
            baseDir: './'
          }
        }
      }
    },

    // Copy web assets from bower_components to more convenient directories.
    copy: {
      main: {
        files: [
          // Vendor scripts.
          {
            expand: true,
            cwd: 'bower_components/bootstrap-sass/assets/javascripts/',
            src: ['**/*.js'],
            dest: 'scripts/bootstrap-sass/'
          }, {
            expand: true,
            cwd: 'bower_components/jquery/dist/',
            src: ['**/*.js', '**/*.map'],
            dest: 'scripts/jquery/'
          }, {
            expand: true,
            cwd: 'bower_components/moment/min/',
            src: ['**/*.js'],
            dest: 'scripts/moment/'
          },

          // Fonts.
          {
            expand: true,
            filter: 'isFile',
            flatten: true,
            cwd: 'bower_components/',
            src: ['bootstrap-sass/assets/fonts/**'],
            dest: 'fonts/'
          },

          // Stylesheets
          {
            expand: true,
            cwd: 'bower_components/bootstrap-sass/assets/stylesheets/',
            src: ['**/*.scss'],
            dest: 'scss/'
          }
        ]
      },
    },

    // Compile SASS files into minified CSS.
    sass: {
      options: {
        includePaths: ['bower_components/bootstrap-sass/assets/stylesheets']
      },
      dist: {
        options: {
            outputStyle: 'compressed'
        },
        files: {
            'css/app.css': 'scss/app.scss'
        }
      }
    },

    // Watch these files and notify of changes.
    watch: {
      grunt: {
        files: ['Gruntfile.js']
      },

      sass: {
        files: [
            'scss/**/*.scss'
        ],
        tasks: ['sass'],
        options: {
          livereload: true,
        },
      },
      html: {
        files: ['index.html'],
        options: {
          livereload: true
        }
      }
    }
  });

  // Load externally defined tasks. 
  grunt.loadNpmTasks('grunt-sass');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-browser-sync');

  // Establish tasks we can run from the terminal.
  grunt.registerTask('build', ['sass', 'copy']);
  grunt.registerTask('default', ['browserSync', 'build', 'watch']);
}

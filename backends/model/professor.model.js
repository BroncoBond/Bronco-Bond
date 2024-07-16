const mongoose = require('mongoose');
const db = require('../config/db');
const { Schema } = mongoose;

const professorSchema = new Schema(
  {
    email: {
      type: String,
      lowercase: true,
      required: true,
      unique: true,
      required: true,
    },
    name: {
      type: String,
      required: true,
    },
    picture: {
      data: Buffer,
      contentType: String,
    },
    degree: {
      type: String,
      enum: ['Associate', "Bachelor's", "Master's", 'Doctoral'],
      required: true,
    },
    college: {
      type: String,
      enum: [
        'Agriculture',
        'Business Administration',
        'Education and Integrative Studies',
        'Engineering',
        'Environmental Design',
        'Hospitality Management',
        'Letters, Arts, and Social Sciences',
        'Science',
        'Professional and Global Education',
      ],
      required: true,
    },
    department: {
      type: String,
      enum: function () {
        if (this.college === 'Don B. Huntley College of Agriculture') {
          return [
            'Agribusiness & Food Industry Management/Agricultural Science',
            'Animal & Veterinary Sciences',
            'Apparel Merchandising & Management',
            'Nutrition & Food Science',
            'Plant Science',
          ];
        } else if (this.college === 'College of Business Administration') {
          return [
            'Accounting',
            'Computer Information Systems',
            'Finance, Real Estate, & Law',
            'International Business & Marketing',
            'Management & Human Resources',
            'Technology & Operations Management',
          ];
        } else if (
          this.college === 'College of Education and Integrative Studies'
        ) {
          return [
            'Early Childhood Studies',
            'Education',
            'Interdisciplinary General Education',
            'Liberal Studies',
            'Educational Leadership',
          ];
        } else if (this.college === 'College of Engineering') {
          return [
            'Aerospace Engineering',
            'Chemicals & Materials Engineering',
            'Civil Engineering',
            'Electrical & Computer Engineering',
            'Industrial & Manufacturing Engineering',
            'Mechanical Engineering',
          ];
        } else if (this.college === 'College of Environmental Design') {
          return [
            'Architecture',
            'Art',
            'John T. Lyle Center for Regenerative Studies',
            'Landscape Architecture',
            'Urban & Regional Planning',
          ];
        } else if (
          this.college === 'College of Letters, Arts, and Social Sciences'
        ) {
          return [
            'Communication',
            'Economics',
            'English & Modern Languages',
            "Ethnic and Women's Studies",
            'Geography & Anthropology',
            'History',
            'Music',
            'Philosophy',
            'Political Science',
            'Psychology',
            'Sociology',
            'Theatre & New Dance',
          ];
        } else if (this.college === 'College of Science') {
          return [
            'Biological Sciences',
            'Chemistry and Biochemistry',
            'Computer Science',
            'Geological Sciences',
            'Kinesiology & Health Promotion',
            'Mathematics & Statistics',
            'Physics & Astronomy',
          ];
        } else {
          // College of Professional and Global Education and Collins College of Hospitality Management both have a single department
          return [];
        }
      },
    },
    classes: {
      type: [String],
      default: [],
      required: true,
    },
  },
  { timestamps: true }
);

const Professor = db.model('Professor', professorSchema);

module.exports = Professor;

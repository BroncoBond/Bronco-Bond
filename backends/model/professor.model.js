const mongoose = require('mongoose');
const db = require('../config/db');
const { Schema } = mongoose;

const collegesDepartments = {
  'Agriculture': [
    'Agribusiness & Food Industry Management/Agricultural Science',
    'Animal & Veterinary Sciences',
    'Apparel Merchandising & Management',
    'Nutrition & Food Science',
    'Plant Science',
  ],
  'Business Administration': [
    'Accounting',
    'Computer Information Systems',
    'Finance, Real Estate, & Law',
    'International Business & Marketing',
    'Management & Human Resources',
    'Technology & Operations Management',
  ],
  'Education and Integrative Studies': [
    'Early Childhood Studies',
    'Education',
    'Interdisciplinary General Education',
    'Liberal Studies',
    'Educational Leadership',
  ],
  'Engineering': [
    'Aerospace Engineering',
    'Chemicals & Materials Engineering',
    'Civil Engineering',
    'Electrical & Computer Engineering',
    'Industrial & Manufacturing Engineering',
    'Mechanical Engineering',
  ],
  'Environmental Design': [
    'Architecture',
    'Art',
    'John T. Lyle Center for Regenerative Studies',
    'Landscape Architecture',
    'Urban & Regional Planning',
  ],
  'Hospitality Management': [],
  'Letters, Arts, and Social Sciences': [
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
  ],
  'Science': [
    'Biological Sciences',
    'Chemistry and Biochemistry',
    'Computer Science',
    'Geological Sciences',
    'Kinesiology & Health Promotion',
    'Mathematics & Statistics',
    'Physics & Astronomy',
  ],
  'Professional and Global Education': [],
};

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
      required: true,
      enum: Object.keys(collegesDepartments),
    },
    department: {
      type: String,
      validate: {
        validator: function (value) {
          return collegesDepartments[this.college]?.includes(value);
        },
        message: (props) =>
          `${props.value} is not a valid department for the college ${props.path.replace(
            '.department',
            '.college'
          )}`,
      },
    },
    classes: {
      type: [String],
      default: [],
    },
  },
  { timestamps: true }
);

const Professor = db.model('Professor', professorSchema);

module.exports = Professor;

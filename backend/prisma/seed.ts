import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  // Create Companies
  let company1 = await prisma.company.findUnique({ where: { name: 'LTI' } });
  if (!company1) {
    company1 = await prisma.company.create({
      data: { name: 'LTI' },
    });
  }

  // Create Interview Flows
  let interviewFlow1 = await prisma.interviewFlow.findFirst({
    where: { description: 'Standard development interview process' },
  });
  if (!interviewFlow1) {
    interviewFlow1 = await prisma.interviewFlow.create({
      data: { description: 'Standard development interview process' },
    });
  }

  let interviewFlow2 = await prisma.interviewFlow.findFirst({
    where: { description: 'Data science interview process' },
  });
  if (!interviewFlow2) {
    interviewFlow2 = await prisma.interviewFlow.create({
      data: { description: 'Data science interview process' },
    });
  }

  // Create Positions
  let position1 = await prisma.position.findFirst({
    where: { title: 'Senior Full-Stack Engineer', companyId: company1.id },
  });
  if (!position1) {
    position1 = await prisma.position.create({
      data: {
        title: 'Senior Full-Stack Engineer',
        description: 'Develop and maintain software applications.',
        status: 'Open',
        isVisible: true,
        location: 'Remote',
        jobDescription: 'Full-stack development',
        companyId: company1.id,
        interviewFlowId: interviewFlow1.id,
        salaryMin: 50000,
        salaryMax: 80000,
        employmentType: 'Full-time',
        benefits: 'Health insurance, 401k, Paid time off',
        contactInfo: 'hr@lti.com',
        requirements: '3+ years of experience in software development, knowledge in React and Node.js',
        responsibilities: 'Develop, test, and maintain software solutions.',
        companyDescription: 'LTI is a leading HR solutions provider.',
        applicationDeadline: new Date('2024-12-31')
      },
    });
  }

  let position2 = await prisma.position.findFirst({
    where: { title: 'Data Scientist', companyId: company1.id },
  });
  if (!position2) {
    position2 = await prisma.position.create({
      data: {
        title: 'Data Scientist',
        description: 'Analyze and interpret complex data.',
        status: 'Open',
        isVisible: true,
        location: 'Remote',
        jobDescription: 'Data analysis and machine learning',
        companyId: company1.id,
        interviewFlowId: interviewFlow2.id,
        salaryMin: 60000,
        salaryMax: 90000,
        employmentType: 'Full-time',
        benefits: 'Health insurance, 401k, Paid time off, Stock options',
        contactInfo: 'hr@lti.com',
        requirements: 'Master degree in Data Science or related field, proficiency in Python and R',
        responsibilities: 'Analyze data sets to derive business insights and develop predictive models.',
        companyDescription: 'LTI es un proveedor líder de soluciones de RRHH.',
        applicationDeadline: new Date('2024-12-31')
      },
    });
  }

  // Create Candidates
  let candidate1 = await prisma.candidate.findUnique({ where: { email: 'john.doe@gmail.com' } });
  if (!candidate1) {
    candidate1 = await prisma.candidate.create({
      data: {
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@gmail.com',
        phone: '1234567890',
        address: '123 Main St',
        educations: {
          create: [
            {
              institution: 'University A',
              title: 'BSc Computer Science',
              startDate: new Date('2015-09-01'),
              endDate: new Date('2019-06-01'),
            },
          ],
        },
        workExperiences: {
          create: [
            {
              company: 'Eventbrite',
              position: 'Software Developer',
              description: 'Developed web applications',
              startDate: new Date('2019-07-01'),
              endDate: new Date('2021-08-01'),
            },
          ],
        },
        resumes: {
          create: [
            {
              filePath: '/resumes/john_doe.pdf',
              fileType: 'application/pdf',
              uploadDate: new Date(),
            },
          ],
        },
      },
    });
  }

  let candidate2 = await prisma.candidate.findUnique({ where: { email: 'jane.smith@gmail.com' } });
  if (!candidate2) {
    candidate2 = await prisma.candidate.create({
      data: {
        firstName: 'Jane',
        lastName: 'Smith',
        email: 'jane.smith@gmail.com',
        phone: '0987654321',
        address: '456 Elm St',
        educations: {
          create: [
            {
              institution: 'Maryland',
              title: 'MSc Data Science',
              startDate: new Date('2016-09-01'),
              endDate: new Date('2020-06-01'),
            },
          ],
        },
        workExperiences: {
          create: [
            {
              company: 'Gitlab',
              position: 'Data Scientist',
              description: 'Analyzed data sets',
              startDate: new Date('2020-07-01'),
              endDate: new Date('2022-08-01'),
            },
          ],
        },
        resumes: {
          create: [
            {
              filePath: '/resumes/jane_smith.pdf',
              fileType: 'application/pdf',
              uploadDate: new Date(),
            },
          ],
        },
      },
    });
  }

  let candidate3 = await prisma.candidate.findUnique({ where: { email: 'carlos.garcia@example.com' } });
  if (!candidate3) {
    candidate3 = await prisma.candidate.create({
      data: {
        firstName: 'Carlos',
        lastName: 'García',
        email: 'carlos.garcia@example.com',
        phone: '1122334455',
        address: '789 Pine St',
        educations: {
          create: [
            {
              institution: 'Instituto Tecnológico',
              title: 'Ingeniería en Sistemas Computacionales',
              startDate: new Date('2017-01-01'),
              endDate: new Date('2021-12-01'),
            },
          ],
        },
        workExperiences: {
          create: [
            {
              company: 'Innovaciones Tech',
              position: 'Ingeniero de Software',
              description: 'Desarrollo y mantenimiento de aplicaciones de software',
              startDate: new Date('2022-01-01'),
              endDate: new Date('2023-01-01'),
            },
          ],
        },
        resumes: {
          create: [
            {
              filePath: '/resumes/carlos_garcia.pdf',
              fileType: 'application/pdf',
              uploadDate: new Date(),
            },
          ],
        },
      },
    });
  }

  // Create Interview Types (usando findFirst en vez de findUnique)
  let interviewType1 = await prisma.interviewType.findFirst({ where: { name: 'HR Interview' } });
  if (!interviewType1) {
    interviewType1 = await prisma.interviewType.create({
      data: {
        name: 'HR Interview',
        description: 'Assess overall fit, tech stack, salary range and availability',
      },
    });
  }

  let interviewType2 = await prisma.interviewType.findFirst({ where: { name: 'Technical Interview' } });
  if (!interviewType2) {
    interviewType2 = await prisma.interviewType.create({
      data: {
        name: 'Technical Interview',
        description: 'Assess technical skills',
      },
    });
  }

  let interviewType3 = await prisma.interviewType.findFirst({ where: { name: 'Hiring manager interview' } });
  if (!interviewType3) {
    interviewType3 = await prisma.interviewType.create({
      data: {
        name: 'Hiring manager interview',
        description: 'Assess cultural fit and professional goals',
      },
    });
  }

  // Create Interview Steps
  let interviewStep1 = await prisma.interviewStep.findFirst({
    where: {
      interviewFlowId: interviewFlow1.id,
      interviewTypeId: interviewType1.id,
      name: 'Initial Screening',
    },
  });
  if (!interviewStep1) {
    interviewStep1 = await prisma.interviewStep.create({
      data: {
        interviewFlowId: interviewFlow1.id,
        interviewTypeId: interviewType1.id,
        name: 'Initial Screening',
        orderIndex: 1,
      },
    });
  }

  let interviewStep2 = await prisma.interviewStep.findFirst({
    where: {
      interviewFlowId: interviewFlow1.id,
      interviewTypeId: interviewType2.id,
      name: 'Technical Interview',
    },
  });
  if (!interviewStep2) {
    interviewStep2 = await prisma.interviewStep.create({
      data: {
        interviewFlowId: interviewFlow1.id,
        interviewTypeId: interviewType2.id,
        name: 'Technical Interview',
        orderIndex: 2,
      },
    });
  }

  let interviewStep3 = await prisma.interviewStep.findFirst({
    where: {
      interviewFlowId: interviewFlow1.id,
      interviewTypeId: interviewType3.id,
      name: 'Manager Interview',
    },
  });
  if (!interviewStep3) {
    interviewStep3 = await prisma.interviewStep.create({
      data: {
        interviewFlowId: interviewFlow1.id,
        interviewTypeId: interviewType3.id,
        name: 'Manager Interview',
        orderIndex: 2,
      },
    });
  }

  // Create Employees
  let employee1 = await prisma.employee.findUnique({ where: { email: 'alice.johnson@lti.com' } });
  if (!employee1) {
    employee1 = await prisma.employee.create({
      data: {
        companyId: company1.id,
        name: 'Alice Johnson',
        email: 'alice.johnson@lti.com',
        role: 'Interviewer',
      },
    });
  }

  let employee2 = await prisma.employee.findUnique({ where: { email: 'bob.miller@lti.com' } });
  if (!employee2) {
    employee2 = await prisma.employee.create({
      data: {
        companyId: company1.id,
        name: 'Bob Miller',
        email: 'bob.miller@lti.com',
        role: 'Hiring Manager',
      },
    });
  }

  // Create Applications
  let application1 = await prisma.application.findFirst({
    where: {
      positionId: position1.id,
      candidateId: candidate1.id,
    },
  });
  if (!application1) {
    application1 = await prisma.application.create({
      data: {
        positionId: position1.id,
        candidateId: candidate1.id,
        applicationDate: new Date(),
        currentInterviewStep: interviewStep2.id,
      },
    });
  }

  let application2 = await prisma.application.findFirst({
    where: {
      positionId: position2.id,
      candidateId: candidate1.id,
    },
  });
  if (!application2) {
    application2 = await prisma.application.create({
      data: {
        positionId: position2.id,
        candidateId: candidate1.id,
        applicationDate: new Date(),
        currentInterviewStep: interviewStep2.id,
      },
    });
  }

  let application3 = await prisma.application.findFirst({
    where: {
      positionId: position1.id,
      candidateId: candidate2.id,
    },
  });
  if (!application3) {
    application3 = await prisma.application.create({
      data: {
        positionId: position1.id,
        candidateId: candidate2.id,
        applicationDate: new Date(),
        currentInterviewStep: interviewStep2.id,
      },
    });
  }

  let application4 = await prisma.application.findFirst({
    where: {
      positionId: position1.id,
      candidateId: candidate3.id,
    },
  });
  if (!application4) {
    application4 = await prisma.application.create({
      data: {
        positionId: position1.id,
        candidateId: candidate3.id,
        applicationDate: new Date(),
        currentInterviewStep: interviewStep1.id,
      },
    });
  }

  // Create Interviews
  const interviewsToCreate = [
    {
      applicationId: application1.id,
      interviewStepId: interviewStep1.id,
      employeeId: employee1.id,
      interviewDate: new Date(),
      result: 'Passed',
      score: 5,
      notes: 'Good technical skills',
    },
    {
      applicationId: application2.id,
      interviewStepId: interviewStep1.id,
      employeeId: employee1.id,
      interviewDate: new Date(),
      result: 'Passed',
      score: 5,
      notes: 'Excellent data analysis skills',
    },
    {
      applicationId: application3.id,
      interviewStepId: interviewStep1.id,
      employeeId: employee1.id,
      interviewDate: new Date(),
      result: 'Passed',
      score: 4,
      notes: 'Good technical skills',
    }
  ];

  for (const interviewData of interviewsToCreate) {
    const exists = await prisma.interview.findFirst({
      where: {
        applicationId: interviewData.applicationId,
        interviewStepId: interviewData.interviewStepId,
        employeeId: interviewData.employeeId,
      },
    });
    if (!exists) {
      await prisma.interview.create({ data: interviewData });
    }
  }
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
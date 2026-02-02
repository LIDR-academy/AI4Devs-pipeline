import { validateCandidateData } from './validator';

describe('validateCandidateData', () => {
  it('should not throw when valid candidate data is provided', () => {
    const validData = {
      firstName: 'Juan',
      lastName: 'García',
      email: 'juan.garcia@example.com',
      phone: '612345678',
      address: 'Calle Mayor 1',
    };
    expect(() => validateCandidateData(validData)).not.toThrow();
  });

  it('should throw Invalid name when firstName is too short', () => {
    const invalidData = {
      firstName: 'J',
      lastName: 'García',
      email: 'juan@example.com',
    };
    expect(() => validateCandidateData(invalidData)).toThrow('Invalid name');
  });

  it('should throw Invalid email when email format is wrong', () => {
    const invalidData = {
      firstName: 'Juan',
      lastName: 'García',
      email: 'not-an-email',
    };
    expect(() => validateCandidateData(invalidData)).toThrow('Invalid email');
  });

  it('should throw Invalid phone when phone format is wrong', () => {
    const invalidData = {
      firstName: 'Juan',
      lastName: 'García',
      email: 'juan@example.com',
      phone: '123',
    };
    expect(() => validateCandidateData(invalidData)).toThrow('Invalid phone');
  });
});

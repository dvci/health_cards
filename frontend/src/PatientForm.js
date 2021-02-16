import React from "react";
import { useState } from "react";

function PatientForm() {

  const [name, setName] = useState('First Name');
  const [gender, setGender] = useState('Gender');
  const [phone, setPhone] = useState('Phone');
  const [email, setEmail] = useState('Email');
  const [birthDate, setBirthDate] = useState('Date of Birth');


  function handleSubmit() {
    console.log('woo')
  }

  function submitData() {
    fetch("http://localhost:3000/Patient/",
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        mode: 'no-cors',
        body: JSON.stringify({resourceType: 'Patient', name: name})
      }
      )
  }

  function handleChange(event) {
    setName(event.target.value);
    console.log(name);
    console.log(gender)
  }

  return (
    <form onSubmit={submitData}>
      <label>
        First Name:
        <input type="text" value={name} onChange={handleChange} />
      </label>
      <label>Middle Initial:
        <input type="text" value={name} onChange={handleChange} />
      </label>
      <label>Last Name:
        <input type="text" value={name} onChange={handleChange} />
      </label>
      <label>Suffix:
        <input type="text" value={name} onChange={handleChange} />
      </label>
      <label>Gender:
        <input type="text" value={gender} onChange={handleChange} />
      </label>
      <label>Mobile Phone:
        <input type="text" value={phone} onChange={handleChange} />
      </label>
      <label>Email Address:
        <input type="text" value={email} onChange={handleChange} />
      </label>
      <label>Date of Birth:
        <input type="text" value={birthDate} onChange={handleChange} />
      </label>
      <input type="submit" value="Submit" />
    </form>
  );
}

export default PatientForm;

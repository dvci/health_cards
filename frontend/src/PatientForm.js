import React from "react";
import { useState } from "react";

function PatientForm() {
  const [fName, setName] = useState("");
  const [mName, setmName] = useState("");
  const [lName, setLName] = useState("");
  const [suffix, setSuffix] = useState("");
  const [gender, setGender] = useState("");
  const [phone, setPhone] = useState("");
  const [email, setEmail] = useState("");
  const [birthDate, setBirthDate] = useState("");

  function handleSubmit(event) {
    event.preventDefault(); //doesn't let it default submit the form in HTML
    submitData();
    console.log("submitted!");
  }

  function submitData() {
    fetch("http://localhost:8000/Patient", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      mode: "no-cors",
      body: JSON.stringify({
        resourceType: "Patient",
        name: [
          {
            given: [fName, mName],
            family: lName,
            suffix: suffix,
          },
        ],
        gender: gender,
        telecom: [
          {
            phone: phone,
            email: email,
          },
        ],
        birthDate: birthDate,
      }),
    });
  }

  return (
    <form onSubmit={handleSubmit}>
      <label>
        First Name:
        <input
          type="text"
          value={fName}
          onChange={(event) => setName(event.target.value)}
        />
      </label>
      <label>
        Middle Initial:
        <input
          type="text"
          value={mName}
          onChange={(event) => setmName(event.target.value)}
        />
      </label>
      <label>
        Last Name:
        <input
          type="text"
          value={lName}
          onChange={(event) => setLName(event.target.value)}
        />
      </label>
      <label>
        Suffix:
        <input
          type="text"
          value={suffix}
          onChange={(event) => setSuffix(event.target.value)}
        />
      </label>
      <label>
        Gender:
        <input
          type="text"
          value={gender}
          onChange={(event) => setGender(event.target.value)}
        />
      </label>
      <label>
        Mobile Phone:
        <input
          type="text"
          value={phone}
          onChange={(event) => setPhone(event.target.value)}
        />
      </label>
      <label>
        Email Address:
        <input
          type="text"
          value={email}
          onChange={(event) => setEmail(event.target.value)}
        />
      </label>
      <label>
        Date of Birth:
        <input
          type="text"
          value={birthDate}
          onChange={(event) => setBirthDate(event.target.value)}
        />
      </label>
      <input type="submit" value="Submit" />
    </form>
  );
}

export default PatientForm;

import React from "react";
import { useState } from "react";

function PatientForm() {
  const [name, setName] = useState("");
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
    //var pat = new Patient();
    //var patEntry = client.Create(pat);
    fetch("http://localhost:8000/Patient/", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      mode: "no-cors",
      body: JSON.stringify({
        resourceType: "Patient",
        name: [
          {
            given: [name, mName],
            family: lName,
            Suffix: suffix,
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
          value={name}
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

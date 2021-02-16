import React from "react";
import { useState } from "react";

function PatientForm() {
  const [name, setName] = useState("Bob");

  function submitData() {
    fetch("https://webhook.site/654fb84b-082a-41aa-87e5-f05a5a62b1bb", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      mode: "no-cors",
      body: JSON.stringify({ resourceType: "Patient", name: name }),
    });
  }

  function handleChange(event) {
    setName(event.target.value);
    console.log(name);
  }

  return (
    <form onSubmit={submitData}>
      <label>
        First Name:
        <input type="text" value={name} onChange={handleChange} />
      </label>
      <input type="submit" value="Submit" />
    </form>
  );
}

export default PatientForm;

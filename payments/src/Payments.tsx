import * as R from 'ramda';

const Payments = () => {
  const name = R.head(["Payments", "Other"]);
  return (
    <div>
      <h1>{name}</h1>
      <p>Start building amazing things with Rsbuild.</p>
    </div>
  );
};

export default Payments;

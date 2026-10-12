import { crearApp } from './app';
import { PUERTO } from './config';

const app = crearApp();

app.listen(PUERTO, () => {
  console.log(`Backend escuchando en http://localhost:${PUERTO}`);
});

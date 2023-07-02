import { update } from 'firebase/database';
import { database, ref, onValue } from './index';

const reference = ref(database, '/');

onValue(reference, (snapshot) => {
    const data = snapshot.val();

    const temperature = data['temperature'];
    const velocity = data['velocity'];

    const tempCntr = temperature['controller'];
    const velCntr = velocity['controller'];

    var sensHtr01 = tempCntr['heater01']['sensor'] as number;
    var contHtr01 = tempCntr['heater01']['control'] as number;

    var sensHtr02 = tempCntr['heater02']['sensor'] as number;
    var contHtr02 = tempCntr['heater02']['control'] as number;

    var sensHtr03 = tempCntr['heater03']['sensor'] as number;
    var contHtr03 = tempCntr['heater03']['control'] as number;

    var sensHtr04 = tempCntr['heater04']['sensor'] as number;
    var contHtr04 = tempCntr['heater04']['control'] as number;

    var sensMtr = velCntr['motor']['sensor'] as number;
    var contMtr = velCntr['motor']['control'] as number;

    if (tempCntr['heater01']['increment'] == true) {
        var value = contHtr01 + 1;
        updateControl('temperature', 'heater01', value);
        tempCntr['heater01']['increment'] == false;
    }
    if (tempCntr['heater02']['increment'] == true) {
        var value = contHtr02 + 1;
        updateControl('temperature', 'heater02', value);
        tempCntr['heater02']['increment'] == false;
    }
    if (tempCntr['heater03']['increment'] == true) {
        var value = contHtr03 + 1;
        updateControl('temperature', 'heater03', value);
        tempCntr['heater03']['increment'] == false;
    }
    if (tempCntr['heater04']['increment'] == true) {
        var value = contHtr04 + 1;
        updateControl('temperature', 'heater04', value);
        tempCntr['heater04']['increment'] == false;
    }



    if (tempCntr['heater01']['decrement'] == true) {
        var value = contHtr01 - 1;
        updateControl('temperature', 'heater01', value);
        tempCntr['heater01']['decrement'] == false;
    }
    if (tempCntr['heater02']['decrement'] == true) {
        var value = contHtr02 - 1;
        updateControl('temperature', 'heater02', value);
        tempCntr['heater02']['decrement'] == false;
    }
    if (tempCntr['heater03']['decrement'] == true) {
        var value = contHtr03 - 1;
        updateControl('temperature', 'heater03', value);
        tempCntr['heater03']['decrement'] == false;
    }
    if (tempCntr['heater04']['decrement'] == true) {
        var value = contHtr04 - 1;
        updateControl('temperature', 'heater04', value);
        tempCntr['heater04']['decrement'] == false;
    }

    if (velCntr['motor']['increment'] == true) {
        var value = contMtr + 1;
        updateControl('velocity', 'motor', value);
        velCntr['motor']['increment'] == false;
    }
    if (velCntr['motor']['decrement'] == true) {
        var value = contMtr - 1;
        updateControl('velocity', 'motor', value);
        velCntr['motor']['decrement'] == false;
    }



    if (sensHtr01 < contHtr01) {
        var value = sensHtr01 + 1
        const path = '/temperature/controller/heater01/';
        const updates = { sensor: value };

        setTimeout(() => update(ref(database, path), updates), 2000);
    }
    if (sensHtr02 < contHtr02) {
        var value = sensHtr02 + 1
        const path = '/temperature/controller/heater02/';
        const updates = { sensor: value };
        
        setTimeout(() => update(ref(database, path), updates), 2000);
    }
    if (sensHtr03 < contHtr03) {
        var value = sensHtr03 + 1
        const path = '/temperature/controller/heater03/';
        const updates = { sensor: value };
        
        setTimeout(() => update(ref(database, path), updates), 2000);
    }
    if (sensHtr04 < contHtr04) {
        var value = sensHtr04 + 1
        const path = '/temperature/controller/heater04/';
        const updates = { sensor: value };
        
        setTimeout(() => update(ref(database, path), updates), 2000);
    }

    if (sensMtr < contMtr) {
        var value = sensMtr + 1
        const path = '/velocity/controller/motor/';
        const updates = { sensor: value };
        
        setTimeout(() => update(ref(database, path), updates), 2000);
    }



    if (sensHtr01 > contHtr01) {
        var value = sensHtr01 - 1
        const path = '/temperature/controller/heater01/';
        const updates = { sensor: value };
        
        setTimeout(() => update(ref(database, path), updates), 2000);
    }
    if (sensHtr02 > contHtr02) {
        var value = sensHtr02 - 1
        const path = '/temperature/controller/heater02/';
        const updates = { sensor: value };
        
        setTimeout(() => update(ref(database, path), updates), 2000);
    }
    if (sensHtr03 > contHtr03) {
        var value = sensHtr03 - 1
        const path = '/temperature/controller/heater03/';
        const updates = { sensor: value };
        
        setTimeout(() => update(ref(database, path), updates), 2000);
    }
    if (sensHtr04 > contHtr04) {
        var value = sensHtr04 - 1
        const path = '/temperature/controller/heater04/';
        const updates = { sensor: value };
        
        setTimeout(() => update(ref(database, path), updates), 2000);
    }

    if (sensMtr > contMtr) {
        var value = sensMtr - 1
        const path = '/velocity/controller/motor/';
        const updates = { sensor: value };
        
        setTimeout(() => update(ref(database, path), updates), 2000);
    }


})

async function updateControl(field: string, component: string, value: number,) {
    const path = '/' + field + '/controller/' + component + '/';
    const updates = { control: value, increment: false, decrement: false };

    update(ref(database, path), updates);
}
